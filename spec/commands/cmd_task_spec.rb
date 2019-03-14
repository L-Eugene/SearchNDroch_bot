# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchndrochBot do
  describe '/task command' do
    before(:each) do
      @player = FactoryBot.create(:user, id: 1)
      allow(@player).to receive(:send_message) { |msg| msg[:text].to_s }

      @game = FactoryBot.create(
        :game,
        start: Time.parse('2050-01-01 17:00:00 UTC+3')
      )
      @game.players << @player

      1.upto(3) do |id|
        @game.levels << FactoryBot.create(
          :level,
          id: id,
          duration: 15,
          task: "Level #{id} task"
        )
      end

      @snd = SearchndrochBot.new

      @chat = FactoryBot.create(:user, id: 3)
      allow(@chat).to receive(:send_message) { |msg| msg[:text] }

      allow(@snd).to receive(:chat) { @player }
      Timecop.freeze('2050-01-01 17:01:00 UTC+3')

      @game.start!
    end

    after(:each) do
      Timecop.return
    end

    it 'should raise error if there is no active games' do
      allow(@snd).to receive(:chat) { @chat }
      expect { @snd.__send__(:process_command, :cmd_task, []) }.to raise_error(SND::GameNotRunning)
    end

    it 'should return correct level task' do
      expect(@snd.__send__(:process_command, :cmd_task, [])).to include('Level 1')
    end

    it 'should calculate time left on level' do
      Timecop.freeze('2050-01-01 17:01:00 UTC+3')
      SND::Game.game_operations
      expect(@snd.__send__(:process_command, :cmd_task, [])).to include '00:14:00'

      Timecop.freeze('2050-01-01 17:17:15 UTC+3')
      SND::Game.game_operations
      expect(@snd.__send__(:process_command, :cmd_task, [])).to include '00:12:45'

      Timecop.freeze('2050-01-01 17:40:11 UTC+3')
      SND::Game.game_operations
      expect(@snd.__send__(:process_command, :cmd_task, [])).to include '00:04:49'
    end
  end
end
