# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchndrochBot do
  describe '/help command' do
    before(:each) do
      @snd = SearchndrochBot.new
      @chat = FactoryBot.create(:user)

      allow(@chat).to receive(:send_message) { |msg| msg[:text] }
      allow(@snd).to receive(:chat) { @chat }
    end

    it 'should return help message' do
      expect(@snd.__send__(:process_command, :cmd_help, [])).to eq SND.t.help
    end
  end
end
