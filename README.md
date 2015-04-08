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

## Contributing

1. Fork it ( https://github.com/BBC-News/alephant-logger-json/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
