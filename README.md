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

---
## Usage

### Logger

You can get a logger by calling the following once Herodotus is installed:

```ruby
logger = DVLA::Herodotus.logger('<system-name>')
```

You can also log out to a file. If you want all the logs in a single file, provide a string of the path to that output file and it will be logged to simultaneously with standard console logger

```ruby
logger = DVLA::Herodotus.logger('<system-name>', output_path: 'logs.txt')
```

Alternatively, if you want each scenario to log out to a separate file based on the scenario name, pass in a lambda that returns a string that attempts to interpolate `@scenario`.

```ruby
logger = DVLA::Herodotus.logger('<system-name>', output_path: -> { "#{@scenario}_log.txt" })
```

This is a standard Ruby logger, so anything that would work on a logger acquired the traditional way will also work here, however it is formatted such that all logs will be output in the following format:


`[SystemName CurrentDate CurrentTime CorrelationId] Level : -- Message`

### Configuration
You can configure Herodotus in the following way to add a Process Id to the output:

```ruby
config = DVLA::Herodotus.config do |config|
  config.display_pid = true
end
logger = DVLA::Herodotus.logger('<system-name>', config: config)
```

This would result in logs in the following format:

`[SystemName CurrentDate CurrentTime CorrelationId PID] Level : -- Message`

### Syncing logs

Herodotus allows you to Sync correlation_ids between instantiated HerodotusLogger objects. 

The HerodotusLogger flagged as `main` will be used as the source.

```ruby
config = DVLA::Herodotus.config do |config|
  config.main = true
end
main_logger = DVLA::Herodotus.logger('<system-name>', config: config)
```

### new_scenario method
You can call `new_scenario` with the identifier just before each scenario to create a unique correlation_id per scenario.

```ruby
logger.new_scenario('Scenario Id')
```

### Strings

Also included is a series of additional methods on `String` that allow you to modify the colour and style of logs. As these exist on `String`, you can call them on any string such as:

```ruby
example_string = 'Multicoloured String'.blue.bg_red.bold
```

| Method        | Function                                         |
|---------------|--------------------------------------------------|
| blue          | Sets the string's colour to blue                 |
| red           | Sets the string's colour to red                  |
| green         | Sets the string's colour to green                |
| brown         | Sets the string's colour to brown                |
| blue          | Sets the string's colour to blue                 |
| magenta       | Sets the string's colour to magenta              |
| cyan          | Sets the string's colour to cyan                 |
| gray          | Sets the string's colour to gray                 |
| grey          | Sets the string's colour to grey (alias of gray) |
| bright_blue   | Sets the string's colour to bright blue          |
| bright_red    | Sets the string's colour to bright red           |
| bright_green  | Sets the string's colour to bright green         |
| bright_yellow | Sets the string's colour to bright yellow        |
| bright_blue   | Sets the string's colour to bright blue          |
| bright_magenta| Sets the string's colour to bright magenta       |
| bright_cyan   | Sets the string's colour to bright cyan          |
| white         | Sets the string's colour to white                |
| bg_blue       | Sets the string's background colour to blue      |
| bg_red        | Sets the string's background colour to red       |
| bg_green      | Sets the string's background colour to green     |
| bg_brown      | Sets the string's background colour to brown     |
| bg_blue       | Sets the string's background colour to blue      |
| bg_magenta    | Sets the string's background colour to magenta   |
| bg_cyan       | Sets the string's background colour to cyan      |
| bg_gray       | Sets the string's background colour to gray      |
| bold          | Sets the string to be bold                       |
| italic        | Sets the string to be italic                     |
| underline     | Sets the string to be underline                  |
| blink         | Sets the string to blink                         |
| reverse_color | Reverses the colour of the string                |

## Development

Herodotus is very lightweight. Currently all code to generate a new logger can be found in `herodotus.rb` and the code for the logger is in `herodotus_logger.rb` so that is the best place to start with any modifications
