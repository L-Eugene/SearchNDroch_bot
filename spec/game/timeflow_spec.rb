# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'db/snd_game'

describe SND::Game do
  describe 'Game start/stop' do
    before(:each) do
      @players = [
        FactoryBot.create(:user, id: 1),
        FactoryBot.create(:user, id: 2)
      ]

      @game = FactoryBot.create(
        :game,
        start: Time.parse('2050-01-01 17:00:00 UTC+3')
      )

      1.upto(3) do |id|
        @game.levels << FactoryBot.create(
          :level,
          id: id,
          duration: 15
        )
      end

      @snd = SearchndrochBot.new

      @players.each do |chat|
        @game.players << chat
      end
    end

    after(:each) do
      Timecop.return
    end

    it 'should not start game until time is come' do
      Timecop.freeze('2049-01-01 17:00:00 UTC+3')
      @snd.periodic

      allow_any_instance_of(SND::Chat).to receive(:send_message)
        .and_raise('Time fault')

      expect { @snd.periodic }.not_to raise_error
      expect(@game.status).to eq 'Future'

      Timecop.freeze('2050-01-01 15:00:00 UTC+3')
      @snd.periodic

      expect { @snd.periodic }.not_to raise_error
      expect(@game.status).to eq 'Future'
    end

    it 'should not start game if it is running' do
      Timecop.freeze('2050-01-01 17:00:00 UTC+3')
      @snd.periodic

      allow_any_instance_of(SND::Chat).to receive(:send_message)
        .and_raise('Time fault')

      @game.update!(status: 'Running')

      expect { @snd.periodic }.not_to raise_error
      expect(@game.status).to eq 'Running'
    end

    it 'should start game' do
      Timecop.freeze('2050-01-01 17:00:00 UTC+3')

      expect(@game.status).to eq 'Future'
      messages = 0
      allow_any_instance_of(SND::Chat)
        .to receive(:send_message) { |_| messages += 1 }
      expect { @snd.periodic }.not_to raise_error
      expect(@game.reload.status).to eq 'Running'
      expect(messages).to eq 4
    end

    it 'should calculate finish time' do
      expect(@game.finish_time).to eq Time.parse('2050-01-01 17:45:00 UTC+3')
    end

    it 'should finish game' do
      Timecop.freeze('2050-01-01 17:45:01 UTC+3')
      @snd.periodic

      @game.update!(status: 'Running')

      messages = 0
      allow_any_instance_of(SND::Chat)
        .to receive(:send_message) { |_| messages += 1 }
      expect { @snd.periodic }.not_to raise_error
      expect(@game.reload.status).to eq 'Over'
      expect(messages).to eq 2
    end

    it 'should detect current level' do
      Timecop.freeze('2050-01-01 17:00:01 UTC+3')

      player = @game.players.first

      # Game is not started
      expect { @game.level(player) }.to raise_error(SND::GameNotRunning)

      @game.start!

      expect(@game.reload.level(player).id).to eq 1

      Timecop.travel(17.minutes)
      @snd.periodic

      expect(@game.reload.level(player).id).to eq 2

      Timecop.travel(17.minutes)
      @snd.periodic

      expect(@game.reload.level(player).id).to eq 3

      # Actually, game is already over
      Timecop.travel(17.minutes)
      @snd.periodic

      expect { @game.reload.level(player).id }.to raise_error(SND::GameNotRunning)
    end

    it 'shoult warn before level-up' do
      messages = 0
      allow_any_instance_of(SND::Chat)
        .to receive(:send_message) { |_| messages += 1 }
      @game.start!

      Timecop.freeze('2050-01-01 17:00:01 UTC+3')
      @snd.periodic

      messages = 0
      expect { @snd.periodic }.not_to raise_error
      expect(messages).to eq 0

      Timecop.freeze('2050-01-01 17:10:55 UTC+3')
      @snd.periodic

      messages = 0
      expect { @snd.periodic }.not_to raise_error
      expect(messages).to eq 2

      Timecop.freeze('2050-01-01 17:11:05 UTC+3')
      @snd.periodic

      messages = 0
      expect { @snd.periodic }.not_to raise_error
      expect(messages).to eq 0

      Timecop.freeze('2050-01-01 17:14:05 UTC+3')
      @snd.periodic

      messages = 0
      expect { @snd.periodic }.not_to raise_error
      expect(messages).to eq 2
    end
  end
end
