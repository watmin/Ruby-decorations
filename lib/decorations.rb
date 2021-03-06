# frozen_string_literal: true

require 'decorations/version'
require 'decorator'

##
# Decorations class to extend within your class
module Decorations
  ##
  # Injects the decorated_methods attribute in the class received
  #
  # @param receiver [Class] the class extending Decorations
  #
  # @return [Void]
  #
  # @api private
  def self.extended(receiver)
    class << receiver
      attr_accessor :decorated_methods
    end
  end

  ##
  # Decorates a method execute's the klass' #call method around the decorated method
  #
  # @return [Void]
  #
  # @example
  #   class DecoratorDemo < Decorator
  #     def call(this, chain, *args)
  #       puts "'#{decorated_class}' has '#{decorated_method.name}' decorated"
  #       call_next(this, chain, *args)
  #     end
  #   end
  #
  #   class Demo
  #     extend Decorations
  #
  #     decorate DecoratorDemo
  #     def demo_method
  #       puts 'am I decorated?'
  #     end
  #   end
  #
  #   demo = Demo.new
  #   demo.demo_method
  #   # => 'Demo' has 'demo_method' decorated
  #   # => am I decorated?
  #
  # @api public
  def decorate(klass, *args, &block)
    @decorators ||= []
    @decorators << { klass: klass, args: args, block: block }
  end

  private

  ##
  # Builds an array of decorators for the method
  #
  # @param name [Symbol] the method name being decorated
  #
  # @return [Array<Decorator>]
  #
  # @api private
  def build_decorators(name)
    decorated_methods[name].map do |decoration|
      decorator = decoration[:klass].new(*decoration[:args], &decoration[:block])
      decorator.__send__(:decorated_class=, decoration[:decorated_class])
      decorator.__send__(:decorated_method=, decoration[:decorated_method])

      decorator
    end
  end

  ##
  # Hooks the methods defined for a class
  #
  # @param name [Symbol] the name of the method being defined
  #
  # @return [Void]
  #
  # @api private
  def method_added(name)
    return unless @decorators

    @decorated_methods ||= Hash.new { |h, k| h[k] = [] }
    @decorated_methods[name] = @decorators.map do |decorator|
      decorator.merge(
        decorated_class: self,
        decorated_method: instance_method(name)
      )
    end
    @decorators = nil

    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def #{name}(*args, &block)
        chain = self.class.__send__(:build_decorators, #{name.inspect})
        Decorator.new.__send__(:call, self, chain, *args, &block)
      end
    RUBY_EVAL
  end
end
