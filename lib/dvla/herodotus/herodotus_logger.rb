require 'securerandom'

module DVLA
  module Herodotus
    class HerodotusLogger < Logger
      attr_accessor :system_name, :requires_pid, :merge, :correlation_ids

      def register_default_correlation_id
        @correlation_ids = { default: SecureRandom.uuid[0, 8] }
        @current_scenario = :default
        reset_format
      end

      def new_scenario(scenario_id)
        update_format(scenario_id)
        merge_correlation_ids(new_scenario: scenario_id) if @merge
      end

      def merge_correlation_ids(new_scenario: nil)
        ObjectSpace.each_object(DVLA::Herodotus::HerodotusLogger) do |logger|
          unless logger == self # This copies the correlation ids this logger has over to all other loggers and (assuming a new scenario has just been switched to) updates the those loggers to the current scenario
            logger.merge = false if logger.merge #Stops the other logger from trying to propagate its correlation ids to all other loggers, otherwise this code ends up in an infinite loop
            logger.correlation_ids = self.correlation_ids
            logger.new_scenario(new_scenario) unless new_scenario.nil?
          end
        end
      end

      %i[debug info warn error fatal].each do |log_level|
        define_method log_level do |progname = nil, scenario_id = nil, &block|
          if scenario_id == nil
            set_proc_writer_scenario
            super(progname, &block)
          else
            update_format(scenario_id)
            set_proc_writer_scenario
            super(progname, &block)
            reset_format
          end
        end
      end

    private

      def update_format(scenario_id)
        @current_scenario = scenario_id
        @correlation_ids[scenario_id] = SecureRandom.uuid[0, 8] unless @correlation_ids.key?(scenario_id)

        self.formatter = proc do |severity, _datetime, _progname, msg|
          "[#{@system_name}" \
            "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} " \
            "#{@correlation_ids[scenario_id]}" \
            "#{' '.concat(Process.pid.to_s) if requires_pid}] " \
            "#{severity} -- : #{msg}\n"
        end
      end

      def reset_format
        self.formatter = proc do |severity, _datetime, _progname, msg|
          "[#{@system_name}" \
            "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} " \
            "#{@correlation_ids[:default]}" \
            "#{' '.concat(Process.pid.to_s) if requires_pid}] " \
            "#{severity} -- : #{msg}\n"
        end
      end

      def set_proc_writer_scenario
        if @logdev.dev.is_a? DVLA::Herodotus::MultiWriter and @logdev.dev.targets.any? DVLA::Herodotus::ProcWriter
          proc_writers = @logdev.dev.targets.select { |t| t.is_a? DVLA::Herodotus::ProcWriter }
          proc_writers.each do |pr|
            pr.scenario = @current_scenario
          end
        end
      end
    end
  end
end
