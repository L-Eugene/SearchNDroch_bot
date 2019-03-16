# frozen_string_literal: true

require 'parser/snd_parser'

module SND
  # Class for parsing game scenario from YAML file
  class YamlParser < Parser
    def self.extensions
      %w[yml yaml]
    end

    def parse
      @game
    end

    def valid?
      return @valid unless @valid.nil?

      @valid = valid_file? && valid_game?
    end

    def valid_file?
      SND.log.debug "Validating file #{file.path}"
      @game = YAML.load_file(file.path).symbolize_keys
    rescue StandardError
      @errors << SND.t.parser.invalid_format(error: $ERROR_INFO.message)
    ensure
      @errors.empty?
    end

    def valid_game?
      @errors << SND.t.parser.game_parameters_missing unless %i[name description start].all? { |key| @game.key? key }

      valid_date?(@game[:start], SND.t.parser.start, true)

      unless @game.key?(:levels) && @game[:levels].is_a?(Array)
        @errors << SND.t.parser.no_levels_given
        return false
      end

      @game[:levels].each do |level|
        validate_level level
      end

      @errors.empty?
    end

    # @param [Hash] level
    # rubocop:disable Metrics/AbcSize
    def validate_level(level)
      unless %i[name task duration to_pass codes].all? { |key| level.key? key }
        return @errors << SND.t.parser.level_parameters(name: level[:name] || 'Unnamed level')
      end

      validate_codes(level[:codes], level[:name])

      unless level[:to_pass]&.to_i&.positive? && level[:codes]&.size.to_i >= level[:to_pass]&.to_i
        @errors << SND.t.parser.level_limit(name: level[:name])
      end

      @errors << SND.t.parser.level_timeout(name: level[:name]) unless level[:duration].to_i.positive?
    end
    # rubocop:enable Metrics/AbcSize

    # @param [Array<Hash>] codes
    # @param [String] name Level name
    # rubocop:disable Metrics/AbcSize
    def validate_codes(codes, name)
      return @errors << SND.t.parser.level_codes(name: level[:name]) unless codes&.size.to_i.positive?

      unless codes.all? { |code| code.key?(:codes) && code.key?(:bonus) }
        return @errors << SND.t.parser.codes_invalid(name: name)
      end

      codes.each_with_index do |code, idx|
        @errors << SND.t.parser.codes_not_array(name: name, code: idx) unless code[:codes].is_a?(Array)
        @errors << SND.t.parser.codes_bonus(name: name, code: idx) unless code[:bonus].to_i.positive?
      end
    end
    # rubocop:enable Metrics/AbcSize

    private :valid_file?, :valid_game?, :validate_level, :validate_codes
  end
end
