# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchndrochBot do
  describe '/move_start command' do
    before(:each) do
      chat = FactoryGirl.create(:user)

      g = FactoryGirl.create(
        :game,
        name: 'Game#1',
        id: 1,
        start: Time.parse('2020-04-04 18:17:00 UTC+3')
      )
      chat.own_games << g

      FactoryGirl.create(:game, name: 'Game#2', id: 2)

      @snd = SearchndrochBot.new

      allow(chat).to receive(:send_message) { |msg| msg[:text] }
      allow(@snd).to receive(:chat) { chat }
    end

    it 'should validate given parameters' do
      # Game id is integer number greater than 0
      expect { @snd.send(:cmd_move_start, '/move_start text') }
        .to raise_error(SND::InvalidGameNumberError)
      expect { @snd.send(:cmd_move_start, '/move_start') }
        .to raise_error(SND::InvalidGameNumberError)
      expect { @snd.send(:cmd_move_start, '/move_start -5') }
        .to raise_error(SND::InvalidGameNumberError)
      expect { @snd.send(:cmd_move_start, '/move_start 0') }
        .to raise_error(SND::InvalidGameNumberError)

      # Should validate Time format
      expect { @snd.send(:cmd_move_start, '/move_start 1') }
        .to raise_error(SND::InvalidTimeFormat)
      expect { @snd.send(:cmd_move_start, '/move_start 1 asd') }
        .to raise_error(SND::InvalidTimeFormat)

      # Game with given id should exist
      expect { @snd.send(:cmd_move_start, '/move_start 3 2020-07-01') }
        .to raise_error(SND::DefunctGameNumberError)

      # Given game should belong to current user
      expect { @snd.send(:cmd_move_start, '/move_start 2 2020-07-01') }
        .to raise_error(SND::GameOwnerError)

      # Should check if given date in future
      expect { @snd.send(:cmd_move_start, '/move_start 1 2010-07-01') }
        .to raise_error(SND::TimeInPastError)
    end

    it 'should move game start' do
      expect do
        @snd.send(:cmd_move_start, '/move_start 1 2120-08-02 01:00:00 +0300')
      end.not_to raise_error
      expect(SND::Game.find(1).start.to_i)
        .to eq(Time.parse('2120-08-02 01:00:00 +0300').to_i)
    end
  end
end
