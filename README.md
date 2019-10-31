# Decorations

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

Create a class that will have decorated methods and create decator classes to before actions.

The decorator class must:
* implement #call
* must invoke call\_next(this, chain, \*args)
* must return the result of call\_next.

```ruby
require 'decorations'

class LoggingDecorator < Decorator
  def call(this, chain, *args)
    puts "[#{Time.now}] #{decorated_class}.#{decorated_method.name} was called"
    result = call_next(this, chain, *args)
    puts "[#{Time.now}] #{decorated_class}.#{decorated_method.name} has finished"
    result
  end
end

class Application
  extend Decorations

  decorate LoggingDecorator
  def perform_task
    2 + 2
  end
end

app = Application.new
app.perform_task
# => [2019-10-31 02:00:31 -0700] LoggingDecorator.perform_task was called
# => [2019-10-31 02:00:31 -0700] LoggingDecorator.perform_task has finished
# => 4
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
