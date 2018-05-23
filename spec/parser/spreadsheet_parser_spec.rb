# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'parser/snd_spreadsheet_parser'

describe SND::SpreadsheetParser do
  before(:all) do
    @file_path = "#{File.dirname(__FILE__)}/../fixtures/spreadsheet_parser/"
    @hash = YAML.load_file "#{@file_path}/hash.yml"
  end

  it 'should parse xls' do
    @sp = SND::SpreadsheetParser.new(
      File.open("#{@file_path}/game.xls", 'r'),
      extension: :xls
    )

    expect(@sp.to_hash).to include(@hash)
  end

  it 'should parse ods' do
    @sp = SND::SpreadsheetParser.new(
      File.open("#{@file_path}/game.ods", 'r'),
      extension: :ods
    )

    expect(@sp.to_hash).to include(@hash)
  end

  it 'should parse xlsx' do
    @sp = SND::SpreadsheetParser.new(
      File.open("#{@file_path}/game.xlsx", 'r'),
      extension: :xlsx
    )

    expect(@sp.to_hash).to include(@hash)
  end

  it 'should validate game options' do
    files = [
      { file: 'hash.yml', error: 'Неверный формат файла' },
      { file: 'game_notime.ods', error: 'Заданы не все параметры игры' },
      { file: 'game_wrongtime.ods', error: 'Неверный формат времени начала' },
      { file: 'game_nolevels.ods', error: 'В игре нет уровней' }
    ]
    files.each do |test|
      @sp = SND::SpreadsheetParser.new(
        File.open("#{@file_path}/#{test[:file]}", 'r'),
        extension: :ods
      )
      expect(@sp.valid).to eq false
      expect(@sp.errors.first).to eq test[:error]
    end
  end

  it 'should collect all validation errors' do
    @sp = SND::SpreadsheetParser.new(
      File.open("#{@file_path}/game_wrongtime_nolevels.ods", 'r'),
      extension: :ods
    )

    expect(@sp.valid).to eq false
    expect(@sp.errors.size).to eq 2
    expect(@sp.errors).to match_array(
      [
        'Неверный формат времени начала',
        'В игре нет уровней'
      ]
    )
  end

  it 'should validate level data' do
    files = [
      { file: 'game_nocodes.ods', error: 'Коды не заданы' },
      {
        file: 'game_wrongleveltime.ods',
        error: 'Продолжительность уровня не задана'
      },
      {
        file: 'game_wrongupcondition.ods',
        error: 'Некорректный порог прохождения'
      }
    ]
    files.each do |test|
      @sp = SND::SpreadsheetParser.new(
        File.open("#{@file_path}/#{test[:file]}", 'r'),
        extension: :ods
      )
      expect(@sp.valid).to eq false
      expect(@sp.errors.first).to include test[:error]
    end
  end
end
