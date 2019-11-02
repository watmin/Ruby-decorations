# frozen_string_literal: true

require 'decorator'

##
# Simple retry decorator
class RetryDecorator < Decorator
  ##
  # Builds a new RetryDecorator
  #
  # @param tries [Integer] Number of retries to make
  # @param from [Class] Exception class to recsue from
  # @param backoff [Boolean] Whether or not sleep between retries
  # @param sleep_duration [Integer] starting sleep value to increment
  #
  # @api private
  def initialize(tries:, from: StandardError, backoff: false, sleep_duration: -1)
    @tries = tries
    @from = from
    @backoff = backoff
    @sleep_duration = sleep_duration
  end

  private

  around
  ##
  # Peforms the retries around the decorated method
  #
  # @return [Void]
  #
  # @api private
  def do_retries
    yield
  rescue @from => e
    raise e unless (@tries -= 1).positive?

    sleep (@sleep_duration += 1)**2 if @backoff # rubocop:disable Lint/ParenthesesAsGroupedExpression
    retry
  end
end
