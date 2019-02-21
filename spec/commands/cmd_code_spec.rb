# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchndrochBot do
  describe 'sending codes' do
    before(:each) do
      @player = FactoryBot.create(:user, id: 1, chat_id: 1)
      @player2 = FactoryBot.create(:user, id: 2, chat_id: -1)
      allow(@player).to receive(:send_message) { |msg| msg[:text].to_s }

      @game = FactoryBot.create(
        :game,
        id: 10,
        name: 'TG1',
        description: 'Test game',
        start: Time.parse('2050-01-01 17:00:00 UTC+3')
      )
      @game.players << @player << @player2

      1.upto(3) do |id|
        level = FactoryBot.create(
          :level,
          id: id,
          duration: 15,
          to_pass: 1,
          task: "Level #{id} task"
        )
        level.codes << FactoryBot.create(
          :code,
          id: 10 * id + 1,
          value: 'as'
        )
        @game.levels << level
      end

      @snd = SearchndrochBot.new

      @chat = FactoryBot.create(:user, id: 3)
      allow(@chat).to receive(:send_message) { |msg| msg[:text].to_s }

      Timecop.freeze('2050-01-01 17:01:00 UTC+3')
      @snd.instance_variable_set(:@time, Time.now)

      @game.start!
    end

    after(:each) do
      Timecop.return
    end

    it 'should raise error if there is no active games' do
      allow(@snd).to receive(:chat) { @chat }
      expect { @snd.__send__(:process_command, :cmd_code, '!23') }.to raise_error(SND::GameNotRunning)
    end

    it 'should return code results' do
      allow(@snd).to receive(:chat) { @player }

      expect(@snd.__send__(:process_command, :cmd_code, '!sa')).to include 'неверный'
      expect(SND::Bonus.all.where(chat: @player).empty?).to be_truthy

      expect(@snd.__send__(:process_command, :cmd_code, '!as')).to include 'верный'
      expect(SND::Bonus.all.where(chat: @player).empty?).not_to be_truthy
      expect(SND::Bonus.all.where(chat: @player).size).to eq 1

      expect(@snd.__send__(:process_command, :cmd_code, '!As')).to include 'уже введен'
      expect(SND::Bonus.all.where(chat: @player).empty?).not_to be_truthy
      expect(SND::Bonus.all.where(chat: @player).size).to eq 1

      expect(@snd.__send__(:process_command, :cmd_code, '!xx')).to include 'неверный'
      expect(SND::Bonus.all.where(chat: @player).empty?).not_to be_truthy
      expect(SND::Bonus.all.where(chat: @player).size).to eq 1
    end

    it 'should warn on codes without exclamation' do
      allow(@snd).to receive(:chat) { @player }
      expect { @snd.__send__(:process_command, :cmd_code, 'sa') }.to raise_exception(SND::InvalidCodeFormat)
      expect(SND::Bonus.all.where(chat: @player).empty?).to be_truthy

      allow(@snd).to receive(:chat) { @player2 }
      expect(@snd.__send__(:process_command, :cmd_code, 'sa')).to be_nil
      expect(SND::Bonus.all.where(chat: @player).empty?).to be_truthy
    end

    it 'should count bonuses for different players separately' do
      allow(@snd).to receive(:chat) { @player }

      expect(@snd.__send__(:process_command, :cmd_code, '!as')).to include 'верный'
      expect(SND::Bonus.all.where(chat: @player).empty?).not_to be_truthy
      expect(SND::Bonus.all.where(chat: @player).size).to eq 1

      allow(@snd).to receive(:chat) { @player2 }

      expect(@snd.__send__(:process_command, :cmd_code, '!as')).to include 'верный'
      expect(SND::Bonus.all.where(chat: @player2).empty?).not_to be_truthy
      expect(SND::Bonus.all.where(chat: @player2).size).to eq 1
    end

    it 'should add correct code to previous level' do
      allow(@snd).to receive(:chat) { @player }

      # Playing at level 2 now
      Timecop.freeze('2050-01-01 17:16:00 UTC+3')
      @snd.instance_variable_set(:@time, Time.now)

      # Putting code to level 2
      expect(@snd.__send__(:process_command, :cmd_code, '!as')).to include 'верный'
      expect(SND::Bonus.all.where(chat: @player).empty?).not_to be_truthy
      expect(SND::Bonus.all.where(chat: @player).size).to eq 1

      # Imitate late submission of correct code
      @snd.instance_variable_set(
        :@time,
        Time.parse('2050-01-01 17:10:00 UTC+3')
      )

      # This code has to be sent to level 1
      expect(@snd.__send__(:process_command, :cmd_code, '!as')).to include 'верный'
      expect(SND::Bonus.all.where(chat: @player).empty?).not_to be_truthy
      expect(SND::Bonus.all.where(chat: @player).size).to eq 2
    end

    describe SND::Monitoring do
      before(:each) do
        [@player, @player2].each do |player|
          allow(@snd).to receive(:chat) { player }
          %w[as xx ww].each do |code|
            @snd.__send__(:process_command, :cmd_code, "!#{code}")
          end
        end
      end

      it 'should store codes in monitoring' do
        expect(SND::Monitoring.all.size).to eq 6
        expect(SND::Monitoring.where(chat: @player).size).to eq 3
      end

      it 'should show valid codes' do
        expect(SND::Monitoring.valid.size).to eq 2
        expect(SND::Monitoring.valid.all? { |m| !m.code.nil? }).to be_truthy
      end

      it 'should show invalid codes' do
        expect(SND::Monitoring.invalid.size).to eq 4
        expect(SND::Monitoring.invalid.all? { |m| m.code.nil? }).to be_truthy
      end
    end
  end
end
