# frozen_string_literal: true

require 'roo'
require 'roo-xls'
require 'parser/snd_parser'

module SND
  # Class for parsing game scenario from spreadsheets
  class SpreadsheetParser < Parser
    attr_reader :doc

    def self.extensions
      %w[ods xls xlsx]
    end

    def parse
      @game = parse_game(doc.sheet(0))
      @game[:levels] = doc.sheets.drop(1).map { |sheet| parse_level doc.sheet(sheet) }
    end

    def valid?
      return @valid unless @valid.nil?

      valid_file?

      @valid = errors.empty? && valid_game? && valid_levels?
    end

    private

    def parse_game(sheet)
      {
        name: sheet.cell(1, 2),
        description: sheet.cell(2, 2),
        start: Time.parse(sheet.cell(3, 2).to_s)
      }
    end

    def parse_level(sheet)
      {
        name: sheet.cell(1, 2),
        task: sheet.cell(2, 2),
        duration: sheet.cell(3, 2).to_i,
        to_pass: sheet.cell(4, 2).to_i,
        codes: parse_codes(sheet)
      }
    end

    def parse_codes(sheet)
      (sheet.first_row..sheet.last_row).to_a.drop(5).map do |row|
        {
          codes: sheet.row(row).map(&:to_s)[1..-1].reject(&:empty?),
          bonus: sheet.cell(row, 1).to_i
        }
      end
    end

    def valid_file?
      raise ArgumentError, SND.t.parser.extension_missing unless options[:extension]

      @doc = Roo::Spreadsheet.open(file.path, extension: options[:extension])
    rescue StandardError
      @errors << SND.t.parser.invalid_format(error: $ERROR_INFO.message)
    end

    def valid_game?
      s0 = doc.sheet(0)
      @errors << SND.t.parser.no_levels_given if doc.sheets.size < 2
      @errors << SND.t.parser.game_parameters_missing if s0.last_row < 3
      valid_date?(s0.cell(3, 2).to_s, SND.t.parser.start)
      @errors.empty?
    end

    def valid_levels?
      @doc.sheets.drop(1).each do |name|
        valid_level?(@doc.sheet(name), name)
      end
      @errors.empty?
    end

    def valid_level?(sheet, name)
      @errors << SND.t.parser.level_timeout(name: name) unless sheet.cell(3, 2).to_i.positive?
      @errors << SND.t.parser.level_codes(name: name) if sheet.last_row < 6

      codes = sheet.last_row - 5
      limit = sheet.cell(4, 2).to_i
      @errors << SND.t.parser.level_limit(name: name) if codes < limit
    end

    private :parse_game, :parse_level, :parse_codes, :valid_file?, :valid_game?, :valid_levels?, :valid_level?
  end
end
