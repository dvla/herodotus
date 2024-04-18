require 'securerandom'

module DVLA
  module Herodotus
    class HerodotusLogger < Logger
      attr_accessor :system_name, :correlation_id, :main, :display_pid, :scenario_id

      # Initializes the logger
      # Sets a default correlation_id and creates the formatter
      # Syncs all instances of the HerodotusLogger when the main flag is present
      # Any subsequent loggers will also be synce
      def initialize(system_name, *args, config: DVLA::Herodotus.config, **kwargs)
        super(*args, **kwargs)

        @system_name = system_name
        @main = config[:main]
        @display_pid = config[:display_pid]

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
      # Needs to be called each time correlation_id is changed after initialization in-order for the changes to take affect.
      def set_formatter
        self.formatter = proc do |severity, _datetime, _progname, msg|
          "[#{@system_name} " \
            "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} " \
            "#{@correlation_id}" \
            "#{' '.concat(Process.pid.to_s) if @display_pid}] " \
            "#{severity} -- : #{msg}\n"
        end
      end

    private

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
