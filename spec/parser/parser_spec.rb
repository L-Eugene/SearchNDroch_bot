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
end
