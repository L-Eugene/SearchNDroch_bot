# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SearchndrochBot do
  before :each do
    @chat = FactoryBot.create(:user)
    @snd = SearchndrochBot.new

    allow(@chat).to receive(:send_message) { |msg| msg[:text] }
    allow(@snd).to receive(:chat) { @chat }
  end

  it 'should extract method name from command' do
    expect(@snd.__send__(:method_from_message, '/test')).to eq('cmd_test')
    expect(@snd.__send__(:method_from_message, '/test 123')).to eq('cmd_test')
    expect(@snd.__send__(:method_from_message, 'test 123')).to eq('cmd_test')
    expect(@snd.__send__(:method_from_message, nil)).to eq('cmd_')
  end

  it 'should parse arguments from command' do
    expect(@snd.__send__(:parse_args, %r{^\/\w+\s?}, '/test')).to eq []
    expect(@snd.__send__(:parse_args, %r{^\/\w+\s?}, '/test 123')).to eq %w[123]
    expect(@snd.__send__(:parse_args, %r{^\/\w+\s?}, 'test 123')).to eq %w[test 123]
  end
end
