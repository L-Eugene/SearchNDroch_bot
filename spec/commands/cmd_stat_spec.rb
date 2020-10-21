# frozen_string_literal: true

require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe SearchndrochBot do
  describe '/stat command' do
    before(:each) do
      @player1 = FactoryBot.create(:user, id: 1, name: 'Player 1')
      allow(@player1).to receive(:send_message) { |msg| msg[:text] }
      @player2 = FactoryBot.create(:user, id: 2, name: 'Player 2')
      allow(@player2).to receive(:send_message) { |msg| msg[:text] }

      @game = FactoryBot.create(
        :game,
        id: 10,
        name: 'TG1',
        description: 'Test game',
        start: Time.parse('2050-01-01 17:00:00 +0300')
      )
      @game.players << @player1
      @game.players << @player2

      level = FactoryBot.create(
        :level,
        id: 1,
        duration: 15,
        task: 'Level 1 task'
      )
      1.upto(10) do |i|
        level.codes << FactoryBot.create(
          :code,
          id: i,
          bonus: 1,
          value: "as#{i}"
        )
      end
      @game.levels << level

      @snd = SearchndrochBot.new

      @chat = FactoryBot.create(:user, id: 3)
      allow(@chat).to receive(:send_message) { |msg| msg[:text] }

      Timecop.freeze('2050-01-01 17:01:00 +0300')
      @snd.instance_variable_set(:@time, Time.current)

      @game.start!

      @t0 = time_to_tz('2050-01-01 17:00:00 +0300')
      @t1 = time_to_tz('2050-01-01 17:01:00 +0300')
      @t2 = time_to_tz('2050-01-01 17:02:00 +0300')
    end

    it 'should raise error if there is no active games' do
      allow(@snd).to receive(:chat) { @chat }
      expect { @snd.__send__(:process_command, :cmd_stat, []) }.to raise_error(SND::GameNotRunning)
    end

    describe 'should build correct statistics' do
      before(:each) do
        SND::Bonus.delete_all
        allow(@snd).to receive(:chat) { @player1 }
      end

      # Nobody has any bonus
      it 'Case 1' do
        expect(@snd.__send__(:process_command, :cmd_stat, []))
          .to include "1. Player 1 [0] (#{@t0})\n2. Player 2 [0] (#{@t0})"
      end

      # Player 2 has more bonuses than Player 1
      it 'Case 2' do
        FactoryBot.create(:bonus, code_id: 1, chat_id: 1, time: Time.current - 5.seconds)
        1.upto(3) do |x|
          FactoryBot.create(:bonus, code_id: x, chat_id: 2, time: Time.current)
        end

        t = time_to_tz('2050-01-01 17:00:55 +0300')

        expect(@snd.__send__(:process_command, :cmd_stat, []))
          .to include "1. Player 2 [3] (#{@t1})\n2. Player 1 [1] (#{t})"
      end

      # Both players has one bonus, but player 1 entered last code earlier
      it 'Case 3' do
        FactoryBot.create(
          :bonus,
          code_id: 1, chat_id: 1, time: Time.current
        )
        FactoryBot.create(
          :bonus,
          code_id: 1, chat_id: 2, time: Time.current + 1.minute
        )

        expect(@snd.__send__(:process_command, :cmd_stat, []))
          .to include "1. Player 1 [1] (#{@t1})\n2. Player 2 [1] (#{@t2})"
      end

      # Both players has one bonus, but player 2 entered last code earlier
      it 'Case 4' do
        FactoryBot.create(
          :bonus,
          code_id: 1, chat_id: 2, time: Time.current
        )
        FactoryBot.create(
          :bonus,
          code_id: 1, chat_id: 1, time: Time.current + 1.minute
        )

        expect(@snd.__send__(:process_command, :cmd_stat, []))
          .to include "1. Player 2 [1] (#{@t1})\n2. Player 1 [1] (#{@t2})"
      end
    end

    it 'should show game stat by id' do
      allow(@snd).to receive(:chat) { @player1 }

      result = @snd.__send__(:process_command, :cmd_stat, ['10'])
      expect(result)
        .to include "1. Player 1 [0] (#{@t0})\n2. Player 2 [0] (#{@t0})"
    end

    it 'should raise if incorrect game given' do
      allow(@snd).to receive(:chat) { @player1 }

      expect { @snd.__send__(:process_command, :cmd_stat, ['2']) }
        .to raise_error(SND::DefunctGameNumberError)
    end
  end
end
