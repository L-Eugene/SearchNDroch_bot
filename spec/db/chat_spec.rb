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
      chat: double('chat', id: 12_334_534, title: nil, first_name: 'User', last_name: 'Name')
    )

    expect(SND::Chat.identify(message).id).to eq 1
  end

  it 'should create chat if it does not exist' do
    message = double(
      chat: double('chat', id: 12_534, title: nil, first_name: 'User', last_name: 'Name')
    )

    expect(SND::Chat.all.size).to eq 1
    expect(SND::Chat.identify(message).id).to eq 2
    expect(SND::Chat.all.size).to eq 2
  end

  it 'should create chat using title if possible' do
    message = double(
      chat: double('chat', id: 12_534, title: 'chat_title_not_name', first_name: 'User', last_name: 'Name')
    )

    expect(SND::Chat.all.size).to eq 1
    expect(SND::Chat.identify(message).id).to eq 2
    expect(SND::Chat.all.size).to eq 2
    expect(SND::Chat.find_by_chat_id(12_534).name).to eq 'chat_title_not_name'
  end

  it 'should detect groups and private chats' do
    # Negative chat_id mean group chat
    c = FactoryBot.create(:user, id: 2, chat_id: -123_432)
    expect(c.private?).to be(false)
    expect(c.group?).to be(true)

    # Positive chat_id mean private chat
    c = FactoryBot.create(:user, id: 3, chat_id: 123_432)
    expect(c.private?).to be(true)
    expect(c.group?).to be(false)
  end
end
