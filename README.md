# DVLA::Herodotus

A Gem that produces loggers that are pre-formatted into an agreed log format

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dvla-herodotus'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dvla-herodotus

## Usage

### Logger

You can get a logger by calling the following once Herodotus is installed:

```ruby
logger = DVLA::Herodotus.logger
```

You can also log out to a file. If you want all the logs in a single file, provide a string of the path to that output file and it will be logged to simultaneously with standard console logger

```ruby
logger = DVLA::Herodotus.logger(output_path: 'logs.txt')
```

Alternatively, if you want each scenario to log out to a separate file based on the scenario name, pass in a lambda that returns a string that attempts to interpolate `@scenario`.

```ruby
logger = DVLA::Herodotus.logger(output_path: -> { "#{@scenario}_log.txt" })
```

This is a standard Ruby logger, so anything that would work on a logger acquired the traditional way will also work here, however it is formatted such that all logs will be output in the following format:

`[CurrentDate CurrentTime CorrelationId] Level : -- Message`

Additionally, you can configure Herodotus in the following way to add a System Name and the Process Id to the output:

```ruby
DVLA::Herodotus.configure do |config|
  config.system_name = 'SystemName'
  config.pid = true
end
```

This would result in logs in the following format:

`[SystemName CurrentDate CurrentTime CorrelationId PID] Level : -- Message`

Additionally, if you wish to have different correlation ids based on the scenario that is being currently being run, you can pass a unique identifier for your scenario as part of the logging call, with each scenario having a unique correlation id.

```ruby
logger.info('String to log out', 'Scenario Id')
```

Alternatively, you can call `new_scenario` with the identifier just before each scenario to achieve the same result without having to pass the identifier around.

```ruby
logger.new_scenario('Scenario Id')
```

Finally, you can set Herodotus up to integrate with any other instances of Herodotus that are loaded indirectly into your application, for example within a gem you use. To take advantage of this, when configuring Herodotus within your project, ensure that you set its `merge` value to true, as below:

```ruby
DVLA::Herodotus.configure do |config|
  config.merge = true
end
```

This will cause your correlation ids to be shared out with all the loggers that exist outside of our direct control. The instance of the Herodotus that will take precedence will be the last one to be loaded, which should be the one you are creating with `DVLA::Herodotus.logger`. 

### Strings

Also included is a series of additional methods on `String` that allow you to modify the colour and style of logs. As these exist on `String`, you can call them on any string such as:

```ruby
example_string = 'Multicoloured String'.blue.bg_red.bold
```

| Method        | Function                                       |
|---------------|------------------------------------------------|
| blue          | Sets the string's colour to blue               |
| red           | Sets the string's colour to red                |
| green         | Sets the string's colour to green              |
| brown         | Sets the string's colour to brown              |
| blue          | Sets the string's colour to blue               |
| magenta       | Sets the string's colour to magenta            |
| cyan          | Sets the string's colour to cyan               |
| gray          | Sets the string's colour to gray               |
| bg_blue       | Sets the string's background colour to blue    |
| bg_red        | Sets the string's background colour to red     |
| bg_green      | Sets the string's background colour to green   |
| bg_brown      | Sets the string's background colour to brown   |
| bg_blue       | Sets the string's background colour to blue    |
| bg_magenta    | Sets the string's background colour to magenta |
| bg_cyan       | Sets the string's background colour to cyan    |
| bg_gray       | Sets the string's background colour to gray    |
| bold          | Sets the string to be bold                     |
| italic        | Sets the string to be italic                   |
| underline     | Sets the string to be underline                |
| blink         | Sets the string to blink                       |
| reverse_color | Reverses the colour of the string              |

## Development

Herodotus is very lightweight. Currently all code to generate a new logger can be found in `herodotus.rb` and the code for the logger is in `herodotus_logger.rb` so that is the best place to start with any modifications
