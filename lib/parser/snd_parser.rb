# frozen_string_literal: true

module SND
  # Basic class for game scenario parser
  class Parser
    attr_accessor :file, :options, :valid, :errors

    def self.extensions
      subclasses.each_with_object([]) do |klass, result|
        result.concat(klass.extensions) if klass.respond_to?(:extensions)
      end
    end

    # @param [String] file
    # @param [String] ext
    # @return [Hash]
    def self.parse(file, ext, chat)
      SND.log.debug { "#{file.try(:path)}: EXT=#{ext}" }
      parser = subclasses.find { |klass| klass.extensions.include? ext }
      raise SND::InvalidFileExtension unless parser

      result = parser.new(file, extension: ext.to_sym)
      raise SND::FileParsingErrors, data: result.errors, chat: chat unless result.valid?

      result.to_hash
    end

    def initialize(file, options = {})
      @game = {}
      @errors = []
      @file = file
      @file = File.open(file) if file.is_a? String
      @options = options
      parse if valid?
    end

    def parse
      raise NotImplementedError, SND.t.error.undefined
    end

    def valid?
      raise NotImplementedError, SND.t.error.undefined
    end

    def to_hash
      @game
    end

    private

    # @param [DateTime] stamp
    # @param [String] place
    # @param [Boolean] check_future
    def valid_date?(stamp, place, check_future = false)
      stamp = Time.parse stamp unless stamp.is_a? Time
      @errors << SND.t.parser.timestamp_in_past if check_future && stamp < Time.current
    rescue StandardError
      @errors << SND.t.parser.invalid_timestamp(place: place)
    end
  end
end
