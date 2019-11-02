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
    next_caller = chain.shift

    self.class.__send__(:before_method)&.each { |method_name| __send__(method_name) }

    ret = if next_caller.nil?
            decorated_method.bind(this).call(*args, &block)
          else
            next_caller.__send__(:call, this, chain, *args, &block)
          end

    self.class.__send__(:after_method)&.each { |method_name| __send__(method_name) }

    ret
  end
end
