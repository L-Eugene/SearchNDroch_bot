# frozen_string_literal: true

require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe SearchndrochBot do
  describe '/name command' do
    before(:each) do
      @player = FactoryBot.create(:user, id: 1, name: 'Player 1')
      allow(@player).to receive(:send_message) { |msg| msg[:text] }

      @snd = SearchndrochBot.new
      allow(@snd).to receive(:chat) { @player }
    end

    it 'should raise if no parameter given' do
      expect { @snd.__send__(:process_command, :cmd_name, []) }.to raise_error(SND::NoParametersGiven)
    end

    it 'should rename user if new name is passed' do
      expect(@snd.chat.name).to eq 'Player 1'
      expect { @snd.__send__(:process_command, :cmd_name, ['NewName']) }.not_to raise_exception
      expect(@snd.chat.name).to eq 'NewName'
      expect { @snd.__send__(:process_command, :cmd_name, %w[New Name]) }.not_to raise_exception
      expect(@snd.chat.name).to eq 'New Name'
    end
  end
end
