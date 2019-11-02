# Decorations

[![Gem Version](https://badge.fury.io/rb/decorations.svg)](https://badge.fury.io/rb/decorations)
[![Build Status](https://travis-ci.org/watmin/Ruby-decorations.svg?branch=master)](https://travis-ci.org/watmin/Ruby-decorations)

Python like decorators for Ruby. Inspired by Rack and previous attempts at decorations

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decorations'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install decorations

## Usage

Create a class that will have decorated methods and create decator classes to be executed around the decorated method.

```ruby
require 'decorations'

class LoggingDecorator < Decorator
  before
  def print_started
    @start_time = Time.now
    puts "[#{@start_time}] #{decorated_class}.#{decorated_method.name} was called"
  end

  after
  def print_finished
    end_time = Time.now
    puts "[#{end_time}] #{decorated_class}.#{decorated_method.name} has finished. Took #{end_time - @start_time} seconds"
  end
end

class Application
  extend Decorations

  decorate LoggingDecorator
  def perform_task(a, b: 2)
    a + b
  end

  decorate LoggingDecorator
  def perform_task_with_a_block
    yield
  end
end

app = Application.new
app.perform_task(2, b: 2)
# [2019-11-01 19:50:59 -0700] Application.perform_task was called
# [2019-11-01 19:50:59 -0700] Application.perform_task has finished. Took 3.51e-05 seconds
# => 4

app.perform_task_with_a_block { puts 'in a block' }
# [2019-11-01 19:55:37 -0700] Application.perform_task_with_a_block was called
# in a block
# [2019-11-01 19:55:37 -0700] Application.perform_task_with_a_block has finished. Took 5.32e-05 seconds
# => nil
```

You can also pass in parameters to decorator methods:

```
class AnotherDecorator < Decorator
  def initialize(some, params)
    @some = some
    @params = params
  end

  before
  def puts_some
    puts @some
  end

  after
  def puts_params
    puts @params
  end
end

class AnotherDemo
  extends Decorations

  decorate AnotherDecorator, 'value 1', 'value 2'
  def another_method
    puts 'running puts in yet another method'
  end
end

demo = AnotherDemo.new
demo.another_method
# value 1
# running puts in yet another method
# value 2
# => nil

```

When testing decorated methods, execute `Decorations.disable` before requiring your source files. In your spec\_helper.rb add the following lines before your library is loaded:

```ruby
require 'decorations'
Decorations.disable
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/watmin/Ruby-decorations. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Decorations project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/watmin/Ruby-decorations/blob/master/CODE_OF_CONDUCT.md).
