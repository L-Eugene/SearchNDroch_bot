# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchndrochBot do
  describe '/cal command' do
    before(:each) do
      @chat1 = FactoryBot.create(:user)
      @chat2 = FactoryBot.create(:user)

      allow(@chat1).to receive(:send_message) { |msg| msg[:text] }
      allow(@chat2).to receive(:send_message) { |msg| msg[:text] }

      10.times do |i|
        @chat1.own_games << FactoryBot.create(:game, id: 20 + i, name: "Game##{20 + i}", status: i < 5 ? 'Over' : 'Future')
        @chat2.own_games << FactoryBot.create(:game, id: i, name: "Game##{i}", status: i < 5 ? 'Over' : 'Future')
      end

      @chat1.own_games << FactoryBot.create(:game, id: 15, name: 'Game#15', status: 'Running')
      @chat2.own_games << FactoryBot.create(:game, id: 16, name: 'Game#16', status: 'Running')

      @snd = SearchndrochBot.new
      allow(@snd).to receive(:chat) { @chat1 }
    end

    it 'should show list of games' do
      expect(@snd.__send__(:process_command, :cmd_cal, []).scan(%r{^[🔜🔚🔛]\s#}).size).to eq 10
    end

    it 'should process /calendar alias command' do
      expect(@snd.__send__(:process_command, :cmd_calendar, []).scan(%r{^[🔜🔚🔛]\s#}).size).to eq 10
    end

    it 'should accept page number' do
      expect(@snd.__send__(:process_command, :cmd_cal, [2]).scan(%r{^[🔜🔚🔛]\s#}).size).to eq 2
    end

    it 'should show empty list of games' do
      SND::Game.delete_all
      expect(@snd.__send__(:process_command, :cmd_calendar, [])).to eq 'Нет активных или ожидаемых игр'
    end
  end
end
