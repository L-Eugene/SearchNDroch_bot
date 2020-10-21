# frozen_string_literal: true

require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe SearchndrochBot do
  describe '/list command' do
    before(:each) do
      @chat1 = FactoryBot.create(:user)
      @chat2 = FactoryBot.create(:user)

      allow(@chat1).to receive(:send_message) { |msg| msg[:text] }
      allow(@chat2).to receive(:send_message) { |msg| msg[:text] }

      25.times do |i|
        @chat2.own_games << FactoryBot.create(:game, name: "Game##{i}")
      end

      @snd = SearchndrochBot.new
    end

    it 'should show list of games' do
      allow(@snd).to receive(:chat) { @chat2 }
      expect(@snd.__send__(:process_command, :cmd_list, []).scan(%r{^[🔜🔚🔛]\s#}).size).to eq 10
    end

    it 'should accept page number' do
      allow(@snd).to receive(:chat) { @chat2 }
      expect(@snd.__send__(:process_command, :cmd_list, [3]).scan(%r{^[🔜🔚🔛]\s#}).size).to eq 5
    end

    it 'should show empty list of games' do
      allow(@snd).to receive(:chat) { @chat1 }
      expect(@snd.__send__(:process_command, :cmd_list, [])).to eq 'У Вас нет игр'
    end
  end
end
