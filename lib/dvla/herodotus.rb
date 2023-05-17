require 'logger'
require_relative 'herodotus/string'
require_relative 'herodotus/herodotus_logger'

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

    def self.logger
      logger = HerodotusLogger.new($stdout)
      logger.system_name = "#{config.system_name} " unless config.system_name.nil?
      logger.requires_pid = config.pid
      logger.merge = config.merge
      logger.register_default_correlation_id
      logger.merge_correlation_ids if config.merge
      logger
    end
  end
end
