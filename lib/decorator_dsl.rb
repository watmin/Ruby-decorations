# frozen_string_literal: true

require 'set'

##
# DSL for Decorator to define before and after hooks for a wrapped method
module DecoratorDsl
  ##
  # Injects the DSL attributes in the class received
  #
  # @param receiver [Class] the class extending DecoratorDsl
  #
  # @return [Void]
  #
  # @api private
  def self.extended(receiver)
    class << receiver
      private

      attr_accessor :before_method, :before_set, :after_method, :after_set
    end
  end

  ##
  # Adds the next method to be hook into executing before decorated method
  #
  # @return [Void]
  #
  # @example
  #   class DecoratorDemo < Decorator
  #     before :print_message
  #     def print_message(this, chain, *args)
  #       puts "'#{decorated_class}' has '#{decorated_method.name}' decorated"
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
  def before
    @before_method ||= Set.new
    @before_set = true
  end

  ##
  # Adds the next method to be hook into executing after decorated method
  #
  # @return [Void]
  #
  # @example
  #   class DecoratorDemo < Decorator
  #     after
  #     def print_message(this, chain, *args)
  #       puts "'#{decorated_class}' has '#{decorated_method.name}' decorated"
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
  #   # => am I decorated?
  #   # => 'Demo' has 'demo_method' decorated
  #
  # @api public
  def after
    @after_method ||= Set.new
    @after_set = true
  end

  private

  ##
  # Hooks the methods defined for a class
  #
  # @param name [Symbol] the name of the method being defined
  #
  # @return [Void]
  #
  # @api private
  def method_added(name)
    if before_set
      @before_set = false
      @before_method << name
    end

    return unless after_set

    @after_set = false
    @after_method << name
  end
end
