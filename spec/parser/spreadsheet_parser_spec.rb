# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'parser/snd_spreadsheet_parser'

describe SND::SpreadsheetParser do
  before(:all) do
    @file_path = "#{File.dirname(__FILE__)}/../fixtures/spreadsheet_parser/"
    @hash = YAML.load_file "#{@file_path}/hash.yml"
  end

  it 'should return extension list' do
    expect(SND::SpreadsheetParser.extensions).to match_array %w[xls ods xlsx]
  end

  it 'should parse xls' do
    sp = SND::SpreadsheetParser.new(
      File.open("#{@file_path}/game.xls", 'r'),
      extension: :xls
    )

    expect(sp.to_hash).to include(@hash)
  end

  it 'should parse ods' do
    sp = SND::SpreadsheetParser.new(
      File.open("#{@file_path}/game.ods", 'r'),
      extension: :ods
    )

    expect(sp.to_hash).to include(@hash)
  end

  it 'should parse xlsx' do
    sp = SND::SpreadsheetParser.new(
      File.open("#{@file_path}/game.xlsx", 'r'),
      extension: :xlsx
    )

    expect(sp.to_hash).to include(@hash)
  end

  files = [
    { title: 'file format', file: 'hash.yml', error: SND.t.parser.invalid_format },
    {
      title: 'start time presence', file: 'game_notime.ods',
      error: SND.t.parser.game_parameters_missing.to_s.lines.first
    },
    {
      title: 'start time format', file: 'game_wrongtime.ods',
      error: SND.t.parser.invalid_timestamp(place: SND.t.parser.start)
    },
    { title: 'start time to be in future', file: 'game_pasttime.ods', error: SND.t.parser.timestamp_in_past },
    { title: 'level presence', file: 'game_nolevels.ods', error: SND.t.parser.no_levels_given }
  ]
  files.each do |test|
    it "should validate #{test[:title]}" do
      sp = SND::SpreadsheetParser.new(
        File.open("#{@file_path}/#{test[:file]}", 'r'),
        extension: :ods
      )
      expect(sp.valid).to eq false
      expect(sp.errors.first).to include test[:error]
    end
  end

  it 'should collect all validation errors' do
    sp = SND::SpreadsheetParser.new(
      File.open("#{@file_path}/game_wrongtime_nolevels.ods", 'r'),
      extension: :ods
    )

    expect(sp.valid).to eq false
    expect(sp.errors.size).to eq 2
    expect(sp.errors).to match_array(
      [
        SND.t.parser.invalid_timestamp(place: SND.t.parser.start),
        SND.t.parser.no_levels_given
      ]
    )
  end

  files = [
    {
      title: 'codes presence', file: 'game_nocodes.ods',
      error: SND.t.parser.level_codes(name: 'Level 1')
    },
    {
      title: 'level time format', file: 'game_wrongleveltime.ods',
      error: SND.t.parser.level_timeout(name: 'Level 1')
    },
    {
      title: 'levelup condition', file: 'game_wrongupcondition.ods',
      error: SND.t.parser.level_limit(name: 'Level 1')
    }
  ]
  files.each do |test|
    it "should validate #{test[:title]}" do
      @sp = SND::SpreadsheetParser.new(
        File.open("#{@file_path}/#{test[:file]}", 'r'),
        extension: :ods
      )
      expect(@sp.valid).to eq false
      expect(@sp.errors.first.to_s).to include test[:error].to_s
    end
  end
end
