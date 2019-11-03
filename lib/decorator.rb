# frozen_string_literal: true

require 'decorator_dsl'

##
# Base decorator class
class Decorator
  extend DecoratorDsl

  private

  ##
  # @!attribute [a] decorated_class
  # The class being decorated
  #
  # @return [Class]
  #
  # @api private
  attr_accessor :decorated_class

  ##
  # @!attribute [a] decorated_class
  # The method being decorated
  #
  # @return [Symbol]
  #
  # @api private
  attr_accessor :decorated_method

  ##
  # The hook to call chained decorations
  #
  # @param this [Instance] the instance of the object with the wrapper method
  # @param chain [Array<Decorator>] the remaining decorators to be called
  # @param args [Array<Object>] the arguments to pass to the wrapper method
  # @param block [Proc] the block to pass to the wrapped method
  #
  # @return [Object] the return value of the next_caller
  #
  # @api private
  def call(this, chain, *args, &block)
    execute_before_methods
    ret = execute_around_methods(build_next_caller(this, chain, *args, &block))
    execute_after_methods

    ret
  end

  ##
  # Produces a proc that invokes the next caller
  #
  # @param this [Instance] the instance of the object with the wrapper method
  # @param chain [Array<Decorator>] the remaining decorators to be called
  # @param args [Array<Object>] the arguments to pass to the wrapper method
  # @param block [Proc] the block to pass to the wrapped method
  #
  # @return [Proc]
  #
  # @api private
  def build_next_caller(this, chain, *args, &block)
    next_caller = chain.shift

    if next_caller.nil?
      proc { decorated_method.bind(this).call(*args, &block) }
    else
      proc { next_caller.__send__(:call, this, chain, *args, &block) }
    end
  end

  ##
  # Executes the before methods
  #
  # @return [Void]
  #
  # @api private
  def execute_before_methods
    self.class.__send__(:before_method)&.each { |method_name| __send__(method_name) }
  end

  ##
  # Executes the around methods
  #
  # @param next_caller [Proc] the proc to execute the next caller
  #
  # @return [Object] the result of the next_caller
  #
  # @api private
  def execute_around_methods(next_caller)
    arounds = self.class.__send__(:around_method)
    if arounds.nil?
      ret = next_caller.call
    else
      ret = nil
      arounds.each { |method_name| ret = __send__(method_name) { next_caller.call } }
    end

    ret
  end

  ##
  # Executes the after methods
  #
  # @return [Void]
  #
  # @api private
  def execute_after_methods
    self.class.__send__(:after_method)&.each { |method_name| __send__(method_name) }
  end
end
