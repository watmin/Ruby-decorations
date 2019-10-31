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
  #   # => 'DecoratorDemo' has 'demo_method' decorated
  #   # => am I decorated?
  #
  # @api public
  def decorate(klass, *args)
    @decorators ||= []
    @decorators << [klass, args]
  end

  private

  ##
  # Appends the decorators to the decorated_methods hash
  #
  # @param name [Symbol] the method name being decorated
  # @param decorators [Array<Decorator>] the decorators defined
  # @param decorated_methods [Hash] the decorated methods for the class
  #
  # @return [Void]
  #
  # @api private
  def append_decorations(name, decorators, decorated_methods)
    decorators.each do |klass, args|
      decorated_methods[name] << klass.new(klass, instance_method(name), *args)
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
    append_decorations(name, @decorators, @decorated_methods)
    @decorators = nil

    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def #{name}(*args, &blk)
        chain = self.class.decorated_methods[#{name.inspect}].dup
        chain.first.call_next(self, chain, *args, &blk)
      end
    RUBY_EVAL
  end
end
