# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SND::Tpl::Chat do
  before(:each) do
    @chat1 = FactoryBot.create(:user)
    @chat2 = FactoryBot.create(:user)

    allow(@chat1).to receive(:send_message) { |msg| msg[:text] }
    allow(@chat2).to receive(:send_message) { |msg| msg[:text] }

    10.times do |i|
      @chat1.own_games << FactoryBot.create(:game, id: 20 + i, name: "Game##{20 + i}", status: i < 7 ? 'Over' : 'Future')
      @chat2.own_games << FactoryBot.create(:game, id: i, name: "Game##{i}", status: i < 7 ? 'Over' : 'Future')
    end

    @chat1.own_games << FactoryBot.create(:game, id: 15, name: 'Game#15', status: 'Running')
    @chat2.own_games << FactoryBot.create(:game, id: 16, name: 'Game#16', status: 'Running')
  end

  it 'should generate pagination keyboard' do
    expect(SND::Tpl::Chat.keyboard_button('list', '/list 1')).to eq(text: 'list', callback_data: '/list 1')

    kbd = SND::Tpl::Chat.keyboard('list', 25, 1).inline_keyboard
    expect(kbd.size).to eq 1
    expect(kbd.first).to eq([text: '>', callback_data: '/list 2'])

    kbd = SND::Tpl::Chat.keyboard('list', 25, 2).inline_keyboard
    expect(kbd.first.size).to eq 2
    expect(kbd.first).to eq([{ text: '<', callback_data: '/list 1' }, { text: '>', callback_data: '/list 3' }])

    kbd = SND::Tpl::Chat.keyboard('list', 25, 3).inline_keyboard
    expect(kbd.size).to eq 1
    expect(kbd.first).to eq([text: '<', callback_data: '/list 2'])
  end

  it 'should return game list for chat' do
    list = SND::Tpl::Chat.games(@chat1)

    expect(list.size).to eq 11
    ((20...30).to_a + [15]).each do |i|
      expect(list.one? { |str| str.include? "##{i}" }).to be_truthy
    end
  end

  it 'should return future game list' do
    list = SND::Tpl::Chat.games

    [7, 8, 9, 15, 16, 27, 28, 29].each do |i|
      expect(list.one? { |str| str.include? "##{i}" }).to be_truthy
    end
  end
end
