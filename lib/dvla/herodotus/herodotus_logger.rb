require 'securerandom'

module DVLA
  module Herodotus
    class HerodotusLogger < Logger
      attr_accessor :system_name, :correlation_id, :main, :display_pid, :scenario_id, :prefix_colour

      # Initializes the logger
      # Sets a default correlation_id and creates the formatter
      # Syncs all instances of the HerodotusLogger when the main flag is present
      # Any subsequent loggers will also be synced
      def initialize(system_name, *args, config: DVLA::Herodotus.config, **kwargs)
        super(*args, **kwargs)

        @system_name = system_name
        @main = config[:main]
        @display_pid = config[:display_pid]
        @prefix_colour = config[:prefix_colour]
        @colour_methods = build_colour_methods(@prefix_colour)

        @correlation_id = SecureRandom.uuid[0, 8]
        set_formatter

        if DVLA::Herodotus.main_logger && @main
          warn("Main logger already set: '#{DVLA::Herodotus.main_logger.system_name}'. This will be overwritten by '#{system_name}'")
        end

        DVLA::Herodotus.main_logger = self if @main
        sync_correlation_ids if DVLA::Herodotus.main_logger
      end

      # Creates a new correlation_id and re-creates the formatter per scenario.
      # If this method is called on an instance of HerodotusLogger not flagged as main
      # the correlation_id of the main logger will be updated and all logger's correlation_ids re-synced.
      def new_scenario(scenario_id)
        @scenario_id = scenario_id
        @correlation_id = SecureRandom.uuid[0, 8]

        if DVLA::Herodotus.main_logger && self != DVLA::Herodotus.main_logger
          warn('You are calling new_scenario on a non-main logger.')

          DVLA::Herodotus.main_logger.correlation_id = @correlation_id
          DVLA::Herodotus.main_logger.scenario_id = @scenario_id
        end

        set_formatter
        sync_correlation_ids if DVLA::Herodotus.main_logger
      end

      # Finds all instances of HerodotusLogger and updates their correlation_id and scenario_id
      # to match that of the main HerodotusLogger.
      def sync_correlation_ids
        ObjectSpace.each_object(DVLA::Herodotus::HerodotusLogger) do |logger|
          unless logger == DVLA::Herodotus.main_logger
            logger.correlation_id = DVLA::Herodotus.main_logger.correlation_id
            logger.scenario_id = DVLA::Herodotus.main_logger.scenario_id
            logger.set_formatter
          end
        end
      end

      %i[debug info warn error fatal].each do |log_level|
        define_method log_level do |progname = nil, &block|
          set_proc_writer_scenario
          super(progname, &block)
        end
      end

      # Sets the format of the log.
      # Needs to be called each time correlation_id is changed after initialization in-order for the changes to take effect.
      def set_formatter
        self.formatter = proc do |severity, _datetime, _progname, msg|
          now = Time.now
          components = {
            system: @system_name,
            date: now.strftime('%Y-%m-%d'),
            time: now.strftime('%H:%M:%S'),
            correlation: @correlation_id,
            pid: @display_pid ? Process.pid.to_s : nil,
            level: severity,
            separator: '-- :',
          }

          prefix = apply_prefix_colors(components)
          "#{prefix}#{msg}\n"
        end
      end

    private

      VALID_METHODS = %w[
        white black red green brown yellow blue magenta cyan gray grey
        bright_red bright_green bright_blue bright_magenta bright_cyan
        bg_black bg_red bg_green bg_brown bg_yellow bg_blue bg_magenta bg_cyan bg_gray bg_grey bg_white
        bg_bright_red bg_bright_green bg_bright_blue bg_bright_magenta bg_bright_cyan
        bold dim italic underline reverse_colour reverse_color
      ].freeze

      def build_colour_methods(colour_spec)
        case colour_spec
        when Array, String
          methods = colour_spec.is_a?(Array) ? colour_spec : colour_spec.split('.')
          return {} unless methods.all? { |m| VALID_METHODS.include?(m) }

          { prefix: methods.map(&:to_sym) }
        when Hash
          colour_spec.transform_values do |spec|
            next unless spec

            methods = spec.is_a?(Array) ? spec : spec.split('.')
            methods.map(&:to_sym) if methods.all? { |m| VALID_METHODS.include?(m) }
          end.compact
        else
          {}
        end
      end

      def apply_colors(text, color_methods)
        return text unless color_methods

        color_methods.reduce(text) { |str, method| str.public_send(method) }
      end

      def apply_prefix_colors(components)
        if @colour_methods[:prefix]
          bracket_content = [components[:system], components[:date], components[:time], 
                             components[:correlation], components[:pid]].compact.join(' ')
          text = "[#{bracket_content}] #{components[:level]} #{components[:separator]} "
          apply_colors(text, @colour_methods[:prefix])
        elsif @colour_methods.is_a?(Hash) && @colour_methods.any?
          system = apply_colors(components[:system], @colour_methods[:system])
          date = apply_colors(components[:date], @colour_methods[:date])
          time = apply_colors(components[:time], @colour_methods[:time])
          correlation = apply_colors(components[:correlation], @colour_methods[:correlation])
          pid = components[:pid] && apply_colors(components[:pid], @colour_methods[:pid])
          level = apply_colors(components[:level], @colour_methods[:level])
          separator = apply_colors(components[:separator], @colour_methods[:separator])

          bracket_content = [system, date, time, correlation, pid].compact.join(' ')
          result = "[#{bracket_content}] #{level} #{separator} "
          apply_colors(result, @colour_methods[:overall]) || result
        else
          bracket_content = [components[:system], components[:date], components[:time], 
                             components[:correlation], components[:pid]].compact.join(' ')
          "[#{bracket_content}] #{components[:level]} #{components[:separator]} "
        end
      end

      def set_proc_writer_scenario
        if @logdev.dev.is_a?(DVLA::Herodotus::MultiWriter) && @logdev.dev.targets.any?(DVLA::Herodotus::ProcWriter)
          proc_writers = @logdev.dev.targets.select { |t| t.is_a? DVLA::Herodotus::ProcWriter }
          proc_writers.each do |pr|
            pr.scenario = @scenario_id
          end
        end
      end
    end
  end
end
