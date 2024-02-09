require 'logger'
require_relative 'herodotus/herodotus_logger'
require_relative 'herodotus/multi_writer'
require_relative 'herodotus/proc_writer'
require_relative 'herodotus/string'

module DVLA
  module Herodotus
    CONFIG_ATTRIBUTES = %i(system_name pid merge).freeze

    def self.configure
      @config ||= Struct.new(*CONFIG_ATTRIBUTES).new
      yield(@config) if block_given?
      @config
    end

    def self.config
      @config || configure
    end

    def self.logger(output_path: nil)
      logger = create_logger(output_path)
      logger.system_name = "#{config.system_name} " unless config.system_name.nil?
      logger.requires_pid = config.pid
      logger.merge = config.merge
      logger.register_default_correlation_id
      logger.merge_correlation_ids if config.merge
      logger
    end

    private_class_method def self.create_logger(output_path)
      if output_path
        if output_path.is_a? String
          output_file = File.open(output_path, 'a')
          return HerodotusLogger.new(MultiWriter.new(output_file, $stdout))
        elsif output_path.is_a? Proc
          proc_writer = ProcWriter.new(output_path)
          return HerodotusLogger.new(MultiWriter.new(proc_writer, $stdout))
        else
          raise ArgumentError.new 'Unexpected output_path provided. Expecting either a string or a proc'
        end
      end
      HerodotusLogger.new($stdout)
    end
  end
end
