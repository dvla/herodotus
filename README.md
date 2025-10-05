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

You can also log out to a file. If you want all the logs in a single file, provide a string of the path to that output file and it will be logged to simultaneously with standard console logger.

**Note:** Log messages are stripped of colour codes before being saved to file.

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

#### Prefix Colourisation
You can colourise the log prefix in several ways:

**Apply colours to the entire prefix:**
```ruby
config = DVLA::Herodotus.config do |config|
  config.prefix_colour = 'blue.bold'
end
logger = DVLA::Herodotus.logger('<system-name>', config: config)
```

**Use an array of colour methods:**

```ruby
config = DVLA::Herodotus.config do |config|
  config.prefix_colour = %w[blue bold underline]
end
logger = DVLA::Herodotus.logger('<system-name>', config: config)
```

**Apply different colours to individual components:**
```ruby
config = DVLA::Herodotus.config do |config|
  config.prefix_colour = {
    system: 'blue.bold',
    date: 'green',
    time: 'yellow',
    correlation: 'magenta',
    pid: 'cyan',
    level: 'red.bold',
    separator: 'white'
  }
end
logger = DVLA::Herodotus.logger('<system-name>', config: config)
```

The hash keys correspond to different parts of the log prefix:
- `system`: The system name
- `date`: The date portion (YYYY-MM-DD)
- `time`: The time portion (HH:MM:SS)
- `correlation`: The correlation ID
- `pid`: The process ID (when display_pid is enabled)
- `level`: The log level (INFO, WARN, etc.)
- `separator`: The "-- :" separator
- `overall`: Applied to the entire prefix after individual components are coloured

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

Also included is a series of additional methods on `String` that allow you to modify the colour and style of logs.
You can stack multiple method calls to add additional styling and use string interpolation to style different parts of the string


```ruby
  example_string = "#{'H'.red}#{'E'.bright_red}#{'R'.yellow}#{'O'.green}#{'D'.blue}#{'O'.bright_blue}#{'T'.magenta}#{'U'.bright_magenta}#{'S'.cyan}".bold.reverse_colour
```

#### Available String Methods

| Type | Examples |
|------|----------|
| Text Styles | **bold** <span style="opacity:0.6">dim</span> *italic* <u>underline</u> |
| Colors | <span style="color:black">black</span> <span style="color:red">red</span> <span style="color:green">green</span> <span style="color:#B8860B">brown</span> <span style="color:#ffff00">yellow</span> <span style="color:blue">blue</span> <span style="color:magenta">magenta</span> <span style="color:cyan">cyan</span> <span style="color:grey">gray</span> <span style="color:white">white</span> |
| Bright Colors | <span style="color:#ff5555">bright_red</span> <span style="color:#55ff55">bright_green</span> <span style="color:#5555ff">bright_blue</span> <span style="color:#ff55ff">bright_magenta</span> <span style="color:#55ffff">bright_cyan</span> |
| Background Colors | <span style="background:black;color:white">bg_black</span> <span style="background:red;color:white">bg_red</span> <span style="background:green;color:white">bg_green</span> <span style="background:#B8860B;color:white">bg_brown</span> <span style="background:#ffff00;color:black">bg_yellow</span> <span style="background:blue;color:white">bg_blue</span> <span style="background:magenta;color:white">bg_magenta</span> <span style="background:cyan;color:black">bg_cyan</span> <span style="background:grey;color:white">bg_gray</span> <span style="background:white;color:black">bg_white</span> |
| Bright Background Colors | <span style="background:#ff5555;color:white">bg_bright_red</span> <span style="background:#55ff55;color:black">bg_bright_green</span> <span style="background:#5555ff;color:white">bg_bright_blue</span> <span style="background:#ff55ff;color:white">bg_bright_magenta</span> <span style="background:#55ffff;color:black">bg_bright_cyan</span> |
| Utility | strip_colour reverse_colour |

#### To handle differences in spelling the following methods have been given aliases:
| Alias         | Original       |
|---------------|----------------|
| bg_grey       | bg_gray        |
| colorize      | colourise      |
| grey          | gray           |
| reverse_color | reverse_colour |
| strip_color   | strip_colour   |

## Development

Herodotus is very lightweight. Currently, all code to generate a new logger can be found in `herodotus.rb` and the code for the logger is in `herodotus_logger.rb` so that is the best place to start with any modifications
