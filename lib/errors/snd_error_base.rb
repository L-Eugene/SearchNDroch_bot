# frozen_string_literal: true

require 'log/snd_logger'

module SND
  # Basic class for exceptions with telegram message support
  class ErrorBase < StandardError
    include R18n::Helpers
    attr_reader :cmessage

    def initialize(options = {})
      @data = options[:data] if options.key? :data
      @chat = options[:chat] if options.key? :chat
      @cmessage = options[:cmessage] || default_cmessage
      msg = options[:msg] || default_message
      super(msg)
    end

    def process
      SND.log.__send__(log_level, message)
      SND.log.__send__(log_level, @data) unless @data.nil?

      @chat&.send_message(text: cmessage)
    end

    private

    def default_message
      raise 'Should be defined in child class'
    end

    def default_cmessage
      raise 'Should be defined in child class'
    end

    def log_level
      :error
    end
  end
end
