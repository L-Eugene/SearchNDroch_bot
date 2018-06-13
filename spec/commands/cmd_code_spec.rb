# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchndrochBot do
  describe 'sending codes' do
    before(:each) do
      @player = FactoryGirl.create(:user, id: 1)
      allow(@player).to receive(:send_message) { |msg| msg[:text] }

      @game = FactoryGirl.create(
        :game,
        id: 10,
        name: 'TG1',
        description: 'Test game',
        start: Time.parse('2050-01-01 17:00:00 UTC+3')
      )
      @game.players << @player

      1.upto(3) do |id|
        level = FactoryGirl.create(
          :level,
          id: id,
          duration: 15,
          task: "Level #{id} task"
        )
        level.codes << FactoryGirl.create(
          :code,
          id: 10 * id + 1,
          value_hash: Digest::MD5.hexdigest('as')
        )
        @game.levels << level
      end

      @snd = SearchndrochBot.new

      @chat = FactoryGirl.create(:user, id: 3)
      allow(@chat).to receive(:send_message) { |msg| msg[:text] }

      Timecop.freeze('2050-01-01 17:01:00 UTC+3')
      @snd.instance_variable_set(:@time, Time.now)

      @game.start!
    end

    after(:each) do
      Timecop.return
    end

    it 'should raise error if there is no active games' do
      allow(@snd).to receive(:chat) { @chat }
      expect { @snd.send(:cmd_code, '#23') }.to raise_error(SND::GameNotRunning)
    end

    it 'should return code results' do
      allow(@snd).to receive(:chat) { @player }

      expect(@snd.send(:cmd_code, '#sa')).to include 'неверный'
      expect(SND::Bonus.all.where(chat: @player).empty?).to be_truthy

      expect(@snd.send(:cmd_code, '#as')).to include 'верный'
      expect(SND::Bonus.all.where(chat: @player).empty?).not_to be_truthy
      expect(SND::Bonus.all.where(chat: @player).size).to eq 1

      expect(@snd.send(:cmd_code, '#as')).to include 'уже введен'
      expect(SND::Bonus.all.where(chat: @player).empty?).not_to be_truthy
      expect(SND::Bonus.all.where(chat: @player).size).to eq 1

      expect(@snd.send(:cmd_code, '#xx')).to include 'неверный'
      expect(SND::Bonus.all.where(chat: @player).empty?).not_to be_truthy
      expect(SND::Bonus.all.where(chat: @player).size).to eq 1
    end

    it 'should add correct code to previous level' do
      allow(@snd).to receive(:chat) { @player }

      # Playing at level 2 now
      Timecop.freeze('2050-01-01 17:16:00 UTC+3')
      @snd.instance_variable_set(:@time, Time.now)

      # Putting code to level 2
      expect(@snd.send(:cmd_code, '#as')).to include 'верный'
      expect(SND::Bonus.all.where(chat: @player).empty?).not_to be_truthy
      expect(SND::Bonus.all.where(chat: @player).size).to eq 1

      # Imitate late submission of correct code
      @snd.instance_variable_set(
        :@time,
        Time.parse('2050-01-01 17:10:00 UTC+3')
      )

      # This code has to be sent to level 1
      expect(@snd.send(:cmd_code, '#as')).to include 'верный'
      expect(SND::Bonus.all.where(chat: @player).empty?).not_to be_truthy
      expect(SND::Bonus.all.where(chat: @player).size).to eq 2
    end
  end
end
