require 'logger'
require 'fileutils'
require_relative 'herodotus/herodotus_logger'
require_relative 'herodotus/multi_writer'
require_relative 'herodotus/proc_writer'
require_relative 'herodotus/string'

module DVLA
  module Herodotus
    class << self
      attr_accessor :main_logger
    end

    CONFIG_ATTRIBUTES = %i[display_pid main prefix_colour].freeze

    def self.config
      config ||= Struct.new(*CONFIG_ATTRIBUTES, keyword_init: true).new
      yield(config) if block_given?
      config
    end

    def self.logger(system_name, config: self.config, output_path: nil)
      create_logger(system_name, config, output_path)
    end

    private_class_method def self.create_logger(system_name, config, output_path)
      if output_path
        if output_path.is_a? String
          ensure_directory_exists(output_path: output_path)
          output_file = File.open(output_path, 'a')
          return HerodotusLogger.new(system_name, MultiWriter.new(output_file, $stdout), config: config)
        elsif output_path.is_a? Proc
          ensure_directory_exists(output_path: output_path.call)
          proc_writer = ProcWriter.new(output_path)
          return HerodotusLogger.new(system_name, MultiWriter.new(proc_writer, $stdout), config: config)
        else
          raise ArgumentError.new 'Unexpected output_path provided. Expecting either a string or a proc'
        end
      end
      HerodotusLogger.new(system_name, $stdout, config: config)
    end

    private_class_method def self.ensure_directory_exists(output_path:)
      directory = File.split(output_path).first
      unless File.directory?(directory)
        FileUtils.mkdir_p(directory)
      end
    end
  end
end
