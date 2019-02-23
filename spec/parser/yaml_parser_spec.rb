# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SND::YamlParser do
  before(:each) do
    @file_path = "#{File.dirname(__FILE__)}/../fixtures/yaml_parser/"
  end

  it 'should return extension list' do
    expect(SND::YamlParser.extensions).to match_array %w[yaml yml]
  end

  it 'should load game' do
    yp = SND::YamlParser.new("#{@file_path}/game.yml")

    expect(yp.valid?).to be_truthy
    expect(yp.to_hash).to eq YAML.load_file("#{@file_path}/game.yml")
  end

  %w[name description start levels].each do |field|
    it "should signalize if #{field} is missing" do
      yp = SND::YamlParser.new("#{@file_path}/game_no_#{field}.yml")

      expect(yp.valid?).to be_falsey
      expect(yp.errors).not_to be_empty
    end
  end

  it 'should signalize if start date is invalid' do
    yp = SND::YamlParser.new("#{@file_path}/game_invalid_date.yml")

    expect(yp.valid?).to be_falsey
    expect(yp.errors).not_to be_empty
  end

  it 'should validate level contents' do
    Dir.glob(%w[level codes].map { |type| "#{@file_path}/game_invalid_#{type}*yml" }).each do |file|
      yp = SND::YamlParser.new(file)

      expect(yp.valid?).to be_falsey
      expect(yp.errors).not_to be_empty
    end
  end
end
