# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchndrochBot do
  describe '/status command' do
    before(:each) do
      @player = FactoryBot.create(:user, id: 1)
      allow(@player).to receive(:send_message) { |msg| msg[:text].to_s }

      @game = FactoryBot.create(
        :game,
        id: 10,
        name: 'TG1',
        description: 'Test game',
        start: Time.parse('2050-01-01 17:00:00 +0300')
      )
      @game.players << @player

      level = FactoryBot.create(
        :level,
        id: 1,
        duration: 15,
        to_pass: 10,
        task: 'Level 1 task'
      )
      1.upto(10) do |i|
        level.codes << FactoryBot.create(
          :code,
          id: i,
          bonus: 2,
          value: "as#{i}"
        )
      end
      @game.levels << level

      @snd = SearchndrochBot.new

      @chat = FactoryBot.create(:user, id: 3)
      allow(@chat).to receive(:send_message) { |msg| msg[:text].to_s }

      Timecop.freeze('2050-01-01 17:01:02 +0300')
      @snd.instance_variable_set(:@time, Time.current)

      @game.start!
    end

    after(:each) do
      Timecop.return
    end

    it 'should raise error if there is no active games' do
      allow(@snd).to receive(:chat) { @chat }
      expect { @snd.__send__(:process_command, :cmd_status, []) }.to raise_error(SND::GameNotRunning)
    end

    describe 'should group sectors left' do
      before(:each) do
        SND::Bonus.delete_all
        allow(@snd).to receive(:chat) { @player }
      end

      it 'Case 1' do
        [2, 5, 9].each do |x|
          @snd.__send__(:process_command, :cmd_code, "!as#{x}")
        end
        expect(@snd.__send__(:process_command, :cmd_status, [])).to include '1,3,4,6-8,10'
        expect(@snd.__send__(:process_command, :cmd_status, [])).to include '3 [6'
        expect(@snd.__send__(:process_command, :cmd_status, [])).to include '(7)'
        expect(@snd.__send__(:process_command, :cmd_status, [])).to include '00:13:58'
      end

      it 'Case 2' do
        [5, 9].each do |x|
          @snd.__send__(:process_command, :cmd_code, "!as#{x}")
        end
        expect(@snd.__send__(:process_command, :cmd_status, [])).to include '1-4,6-8,10'
        expect(@snd.__send__(:process_command, :cmd_status, [])).to include '2 [4'
        expect(@snd.__send__(:process_command, :cmd_status, [])).to include '(8)'
      end

      it 'Case 3' do
        expect(@snd.__send__(:process_command, :cmd_status, [])).to include '1-10'
        expect(@snd.__send__(:process_command, :cmd_status, [])).to include '0 [0'
        expect(@snd.__send__(:process_command, :cmd_status, [])).to include '(10)'
      end

      it 'Case 4' do
        2.upto(8) do |x|
          @snd.__send__(:process_command, :cmd_code, "!as#{x}")
        end
        expect(@snd.__send__(:process_command, :cmd_status, [])).to include '1,9,10'
        expect(@snd.__send__(:process_command, :cmd_status, [])).to include '7 [14'
        expect(@snd.__send__(:process_command, :cmd_status, [])).to include '(3)'
      end
    end

    it 'should write when no codes left to search' do
      allow(@snd).to receive(:chat) { @player }
      1.upto(10) do |x|
        @snd.__send__(:process_command, :cmd_code, "!as#{x}")
      end
      expect(@snd.__send__(:process_command, :cmd_status, [])).to include 'Все уровни выполнены'
    end
  end
end
