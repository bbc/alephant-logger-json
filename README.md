# Alephant::Logger::JSON

JSON logging driver for the [alephant-logger](https://github.com/BBC-News/alephant-logger) gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'alephant-logger-json'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install alephant-logger-json

## Usage

```ruby
require "alephant/logger"
require "alephant/logger/json"

json_driver = Alephant::Logger::JSON.new "path/to/logfile.log"

logger = Alephant::Logger.setup json_driver
logger.info({ "some_field" => "some_value", "other_field" => "other_value" })
```

### Nesting

By default, nested JSON values are flattened to strings.  To enable nesting, provided that your log analysis tooling supports that, create `Alephant::Logger::JSON` as follows:

```
Alephant::Logger::JSON.new("path/to/logfile.log", :nesting => true)
```

### Distributed Tracing

The logger will set a key of `uuid` to `n/a` by default for each log request.

This value can be changed by providing a lambda function that contains the logic to determine this value.

There are two methods available to help you:

- `Alephant::Logger::JSON.session?`: boolean response checking if `@@session` has been set
- `Alephant::Logger::JSON.session`: accepts a lambda function (its return value is internally assigned to `@@session`)

When using tracing, you'll need to provide a binding context as the first argument to your log level method calls.

This is to resolve issues with lambda's scope availability. See `Kernal#binding` for more details. 

Example usage:

```
logger.info(binding, :foo => :bar)
```

If no `binding` is provided then tracing is ignored and the logger falls back to its default value.

> Note: you can hide the binding necessity behind an abstraction layer if you prefer

## Contributing

1. Fork it ( https://github.com/BBC-News/alephant-logger-json/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
