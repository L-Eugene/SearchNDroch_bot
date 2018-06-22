# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchndrochBot do
  describe '/stat command' do
    before(:each) do
      @player1 = FactoryGirl.create(:user, id: 1, name: 'Player 1')
      allow(@player1).to receive(:send_message) { |msg| msg[:text] }
      @player2 = FactoryGirl.create(:user, id: 2, name: 'Player 2')
      allow(@player2).to receive(:send_message) { |msg| msg[:text] }

      @game = FactoryGirl.create(
        :game,
        id: 10,
        name: 'TG1',
        description: 'Test game',
        start: Time.parse('2050-01-01 17:00:00 UTC+3')
      )
      @game.players << @player1
      @game.players << @player2

      level = FactoryGirl.create(
        :level,
        id: 1,
        duration: 15,
        task: 'Level 1 task'
      )
      1.upto(10) do |i|
        level.codes << FactoryGirl.create(
          :code,
          id: i,
          bonus: 1,
          value_hash: Digest::MD5.hexdigest("as#{i}")
        )
      end
      @game.levels << level

      @snd = SearchndrochBot.new

      @chat = FactoryGirl.create(:user, id: 3)
      allow(@chat).to receive(:send_message) { |msg| msg[:text] }

      Timecop.freeze('2050-01-01 17:01:00 UTC+3')
      @snd.instance_variable_set(:@time, Time.now)

      @game.start!
    end

    it 'should raise error if there is no active games' do
      allow(@snd).to receive(:chat) { @chat }
      expect { @snd.send(:cmd_stat, '') }.to raise_error(SND::GameNotRunning)
    end

    describe 'should build correct statistics' do
      before(:each) do
        SND::Bonus.delete_all
        allow(@snd).to receive(:chat) { @player1 }
      end

      # Nobody has any bonus
      it 'Case 1' do
        expect(@snd.send(:cmd_stat, ''))
          .to include "1. Player 1 [0]\n2. Player 2 [0]"
      end

      # Player 2 has more bonuses than Player 1
      it 'Case 2' do
        FactoryGirl.create(:bonus, code_id: 1, chat_id: 1, time: Time.now)
        1.upto(3) do |x|
          FactoryGirl.create(:bonus, code_id: x, chat_id: 2, time: Time.now)
        end

        expect(@snd.send(:cmd_stat, ''))
          .to include "1. Player 2 [3]\n2. Player 1 [1]"
      end

      # Both players has one bonus, but player 1 entered last code earlier
      it 'Case 3' do
        FactoryGirl.create(
          :bonus,
          code_id: 1, chat_id: 1, time: '2050-01-01 17:01:00 UTC+3'
        )
        FactoryGirl.create(
          :bonus,
          code_id: 1, chat_id: 2, time: '2050-01-01 17:02:00 UTC+3'
        )

        expect(@snd.send(:cmd_stat, ''))
          .to include "1. Player 1 [1]\n2. Player 2 [1]"
      end

      # Both players has one bonus, but player 2 entered last code earlier
      it 'Case 4' do
        FactoryGirl.create(
          :bonus,
          code_id: 1, chat_id: 2, time: '2050-01-01 17:01:00 UTC+3'
        )
        FactoryGirl.create(
          :bonus,
          code_id: 1, chat_id: 1, time: '2050-01-01 17:02:00 UTC+3'
        )

        expect(@snd.send(:cmd_stat, ''))
          .to include "1. Player 2 [1]\n2. Player 1 [1]"
      end
    end

    it 'should show game stat by id' do
      allow(@snd).to receive(:chat) { @player1 }

      expect(@snd.send(:cmd_stat, '/stat 10'))
        .to include "1. Player 1 [0]\n2. Player 2 [0]"
    end

    it 'should raise if incorrect game given' do
      allow(@snd).to receive(:chat) { @player1 }

      expect { @snd.send(:cmd_stat, '/stat 2') }
        .to raise_error(SND::DefunctGameNumberError)
    end
  end
end
