# frozen_string_literal: true

##
# Base decorator class
class Decorator
  ##
  # @!attribute [r] decorated_class
  # The class being decorated
  #
  # @return [Class]
  #
  # @example
  #   decorator.decoated_class #=> Class
  #
  # @api public
  attr_reader :decorated_class

  ##
  # @!attribute [r] decorated_class
  # The method being decorated
  #
  # @return [Symbol]
  #
  # @example
  #   decorator.decorated_method #=> Symbol
  #
  # @api public
  attr_reader :decorated_method

  ##
  # Decorator constructor interface
  #
  # @param decorated_class [Class] The class that is being decorated
  # @param decorated_method [Symbol] The method that is being decorated
  #
  # @return [Decorator]
  #
  # @api private
  def initialize(decorated_class, decorated_method)
    @decorated_class = decorated_class
    @decorated_method = decorated_method
  end

  ##
  # The hook to call chained decorations
  #
  # @param this [Instance] the instance of the object with the wrapper method
  # @param chain [Array<Decorator>] the remaining decorators to be called
  # @param *args [Array<Object>] the arguments to pass to the wrapper method
  #
  # @return [Object] the return value of the next_caller
  #
  # @example
  #   class DecoratorDemo < Decorator
  #     def call(this, chain, *args)
  #       puts "'#{decorated_class}' has '#{decorated_method.name}' decorated"
  #       call_next(this, chain, *args)
  #     end
  #   end
  #
  # @api public
  def call_next(this, chain, *args)
    next_caller = chain.shift

    if next_caller.nil?
      decorated_method.bind(this).call(*args)
    else
      next_caller.call(this, chain, *args)
    end
  end
end
