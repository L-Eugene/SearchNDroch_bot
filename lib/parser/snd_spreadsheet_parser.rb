# frozen_string_literal: true

require 'roo'
require 'roo-xls'
require 'parser/snd_parser'
require 'digest'

module SND
  # Class for parsing game scenario from spreadsheets
  class SpreadsheetParser < Parser
    attr_reader :doc

    def parse
      @game = parse_game(doc.sheet(0))
      @game[:levels] = doc.sheets.drop(1).map do |sheet|
        parse_level doc.sheet(sheet)
      end
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
          code: Digest::MD5.hexdigest(
            Unicode.downcase(sheet.cell(row, 1).to_s)
          ),
          bonus: sheet.cell(row, 2).to_i
        }
      end
    end

    def valid_date?(stamp, place)
      Time.parse stamp
    rescue StandardError
      @errors << "Неверный формат времени #{place}"
    end

    def valid_file?
      raise ArgumentError, 'Extension is not defined' unless options[:extension]

      @doc = Roo::Spreadsheet.open(file.path, extension: options[:extension])
    rescue StandardError
      @errors << 'Неверный формат файла'
    end

    def valid_game?
      s0 = doc.sheet(0)
      @errors << 'В игре нет уровней' if doc.sheets.size < 2
      @errors << 'Заданы не все параметры игры' if s0.last_row < 3
      valid_date?(s0.cell(3, 2).to_s, 'начала')
      @errors.empty?
    end

    def valid_levels?
      @doc.sheets.drop(1).each do |name|
        valid_level?(@doc.sheet(name), name)
      end
      @errors.empty?
    end

    def valid_level?(sheet, name)
      @errors << "#{name}: Продолжительность уровня не задана" unless sheet.cell(3, 2).to_i.positive?
      @errors << "#{name}: Коды не заданы" if sheet.last_row < 6

      codes = sheet.last_row - 5
      limit = sheet.cell(4, 2).to_i
      @errors << "#{name}: Некорректный порог прохождения" if codes < limit
    end
  end
end
