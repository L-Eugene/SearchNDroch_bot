# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchndrochBot do
  describe '/join command' do
    before(:each) do
      @chat = FactoryGirl.create(:user)

      @game1 = FactoryGirl.create(:game, name: 'Game#1', id: 1)
      @chat.own_games << @game1

      @game2 = FactoryGirl.create(:game, name: 'Game#2', id: 2)

      @snd = SearchndrochBot.new

      allow(@chat).to receive(:send_message) { |msg| msg[:text] }
      allow(@snd).to receive(:chat) { @chat }
    end

    it 'should validate game_id' do
      # Game id is integer number greater than 0
      expect { @snd.send(:cmd_join, '/join text') }
        .to raise_error(SND::InvalidGameNumberError)
      expect { @snd.send(:cmd_join, '/join -5') }
        .to raise_error(SND::InvalidGameNumberError)
      expect { @snd.send(:cmd_join, '/join') }
        .to raise_error(SND::InvalidGameNumberError)
      expect { @snd.send(:cmd_join, '/join 0') }
        .to raise_error(SND::InvalidGameNumberError)

      # Game with given id should exist
      expect { @snd.send(:cmd_join, '/join 3') }
        .to raise_error(SND::DefunctGameNumberError)
    end

    it 'should join game' do
      expect(@chat.games.size).to eq 0
      expect(@game1.players.size).to eq 0
      expect(@game2.players.size).to eq 0

      expect(@snd.send(:cmd_join, '/join 1')).to eq 'Вы заявлены на игру #1'

      expect(@chat.games.reload.size).to eq 1
      expect(@game1.players.reload.size).to eq 1
      expect(@game2.players.reload.size).to eq 0
    end
  end
end
