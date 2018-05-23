# frozen_string_literal: true

require 'singleton'

# Vk module
module SND
  # Logger singleton
  class Log
    include Singleton

    attr_reader :logger

    def initialize
      flag = SND.cfg.options['debug']

      @logger = Logger.new(SND.cfg.options['logfile'], 'daily')
      @logger.level = File.exist?(flag) ? Logger::DEBUG : Logger::INFO
      @logger.formatter = proc do |severity, datetime, _progname, msg|
        date_format = datetime.strftime('%Y-%m-%d %H:%M:%S')
        "[#{date_format}] #{severity}: #{msg}\n"
      end
    end
  end

  def self.log
    SND::Log.instance.logger
  end
end
