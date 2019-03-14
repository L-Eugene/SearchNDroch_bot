# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'parser/snd_spreadsheet_parser'

describe SND::Parser do
  it 'should raise if trying to parse' do
    expect { SND::Parser.new(nil, nil).parse }.to raise_error(NotImplementedError)
  end

  it 'should raise if trying to validate' do
    expect { SND::Parser.new(nil, nil).valid? }.to raise_error(NotImplementedError)
  end

  it 'should raise if invalid file format is sent' do
    expect { SND::Parser.parse('nofile', 'unsupported') }.to raise_error(SND::InvalidFileExtension)
  end

  it 'should return nonempty array of extensions' do
    data = SND::Parser.extensions

    expect(data).to be_a(Array)
    expect(data).not_to be_empty
  end
end
