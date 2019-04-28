# frozen_string_literal: true

require 'singleton'

# Vk module
module SND
  # Logger singleton
  class Log
    include Singleton

    attr_reader :logger

    def initialize
      debug = SND.cfg.options['debug']['enabled'] || File.exist?(SND.cfg.options['debug']['flag'])

      @logger = Logger.new(SND.cfg.options['logfile'])
      @logger.level = debug ? Logger::DEBUG : Logger::INFO
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
