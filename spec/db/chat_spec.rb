# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'db/snd_chat'

describe SND::Chat do
  before(:each) do
    @chat = FactoryBot.create(:user, id: 1, chat_id: 12_334_534)
  end

  it 'should provide needed attributes' do
    expect(@chat).to respond_to(:id)
    expect(@chat).to respond_to(:chat_id)
    expect(@chat).to respond_to(:name)
  end

  it 'should search chat by message' do
    message = double(
      chat: double('chat', id: 12_334_534),
      from: double('from', first_name: 'User', last_name: 'Name')
    )

    expect(SND::Chat.identify(message).id).to eq 1
  end

  it 'should create chat if it does not exist' do
    message = double(
      chat: double('chat', id: 12_534),
      from: double('from', first_name: 'User', last_name: 'Name')
    )

    expect(SND::Chat.all.size).to eq 1
    expect(SND::Chat.identify(message).id).to eq 2
    expect(SND::Chat.all.size).to eq 2
  end
end
