# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchndrochBot do
  describe '/info command' do
    before(:each) do
      @player = FactoryBot.create(:user, id: 1)
      allow(@player).to receive(:send_message) { |msg| msg[:text] }

      @game = FactoryBot.create(
        :game,
        id: 10,
        name: 'TG1',
        description: 'Test game',
        start: Time.parse('2050-01-01 17:00:00 UTC+3')
      )
      @game.players << @player

      @game2 = FactoryBot.create(
        :game,
        id: 11,
        name: 'TG2',
        description: 'Test game #2',
        start: Time.parse('2050-01-01 17:00:00 UTC+3')
      )

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

      Timecop.freeze('2050-01-01 17:01:00 UTC+3')

      @game.start!
    end

    after(:each) do
      Timecop.return
    end

    it 'should raise error if there is no active games' do
      allow(@snd).to receive(:chat) { @chat }
      expect { @snd.send(:cmd_info, []) }.to raise_error(SND::GameNotRunning)
    end

    it 'should return correct game info' do
      allow(@snd).to receive(:chat) { @player }
      expect { @result = @snd.send(:cmd_info, []) }.not_to raise_error
      expect(@result).to include '[10]'
      expect(@result).to include 'TG1'
      expect(@result).to include '2050-01-01'
    end

    it 'shoutd return game info by game id' do
      allow(@snd).to receive(:chat) { @player }
      expect { @result = @snd.send(:cmd_info, [11]) }.not_to raise_error
      expect(@result).to include '[11]'
      expect(@result).to include 'TG2'
    end
  end
end
