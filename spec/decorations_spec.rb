# frozen_string_literal: true

require 'decorations'

class SpecDecorationsDecorator < Decorator
  before
  def before_hook
    puts 'in the before hook'
  end

  after
  def after_hook
    puts 'in the after hook'
  end
end

class SpecDecorations
  extend Decorations

  def unwarpper_method_one; end

  decorate SpecDecorationsDecorator
  def test_method
    true
  end

  def unwarpper_method_two; end
end

RSpec.describe Decorations do
  before(:each) do
    @subject = SpecDecorations.new
  end

  context 'with a decorated method' do
    it 'has the correct number of decorations' do
      @subject.test_method
      expect(@subject.class.instance_variable_get(:@decorated_methods).size).to eq 1
    end

    it 'returns the value from the decorated_method' do
      expect(@subject.test_method).to eq true
    end
  end
end
