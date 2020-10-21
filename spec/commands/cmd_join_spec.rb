# frozen_string_literal: true

require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe SearchndrochBot do
  describe '/join command' do
    before(:each) do
      @chat = FactoryBot.create(:user)

      Timecop.freeze('2019-02-02 17:05:00 +0300')

      @game1 = FactoryBot.create(
        :game,
        name: 'Game#1', id: 1, start: '2019-02-02 20:00:00 +0300', status: 'Future'
      )
      @chat.own_games << @game1

      @game2 = FactoryBot.create(
        :game,
        name: 'Game#2', id: 2, start: '2019-02-02 15:00:00 +0300', status: 'Running'
      )

      1.upto(3) do |id|
        @game2.levels << FactoryBot.create(:level, id: id, duration: 90)
      end

      @snd = SearchndrochBot.new

      allow(@chat).to receive(:send_message) { |msg| msg[:text] }
      allow(@snd).to receive(:chat) { @chat }
    end

    after(:each) do
      Timecop.return
    end

    it 'should validate game_id' do
      # Game id is integer number greater than 0
      expect { @snd.__send__(:process_command, :cmd_join, ['text']) }
        .to raise_error(SND::InvalidGameNumberError)
      expect { @snd.__send__(:process_command, :cmd_join, ['-5']) }
        .to raise_error(SND::InvalidGameNumberError)
      expect { @snd.__send__(:process_command, :cmd_join, []) }
        .to raise_error(SND::InvalidGameNumberError)
      expect { @snd.__send__(:process_command, :cmd_join, ['0']) }
        .to raise_error(SND::InvalidGameNumberError)

      # Game with given id should exist
      expect { @snd.__send__(:process_command, :cmd_join, ['3']) }
        .to raise_error(SND::DefunctGameNumberError)
    end

    it 'should join game' do
      expect(@chat.games.size).to eq 0
      expect(@game1.players.size).to eq 0
      expect(@game2.players.size).to eq 0

      expect(@snd.__send__(:process_command, :cmd_join, ['1'])).to eq 'Вы заявлены на игру #1'

      expect(@chat.games.reload.size).to eq 1
      expect(@game1.players.reload.size).to eq 1
      expect(@game2.players.reload.size).to eq 0
    end

    it 'should set current level when joining active game' do
      allow(@chat).to receive(:send_message) { |p| p }

      expect(@chat.games.reload.size).to eq 0

      result = @snd.__send__(:process_command, :cmd_join, ['2'])

      expect(result[:reply_markup]).to be_a Telegram::Bot::Types::ReplyKeyboardMarkup
      expect(result[:text]).to include 'До автоперехода осталось'

      expect(@chat.games.reload.size).to eq 1

      expect(@game2.level(@game2.game_players.first).id).to eq 2

      lt = SND::LevelTime.by_game_chat(@game2, @game2.game_players.first).last
      expect(lt.start_time).to eq '2019-02-02 16:30:00 +0300'
    end
  end
end
