# frozen_string_literal: true

module SND
  # Basic class for game scenario parser
  class Parser
    attr_accessor :file, :options, :valid, :errors

    def initialize(file, options)
      @game = {}
      @errors = []
      @file = file
      @options = options
      parse if valid?
    end

    def parse
      raise t.error.undefined
    end

    def valid?
      raise t.error.undefined
    end

    def to_hash
      @game
    end
  end
end
