# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchndrochBot do
  before(:each) do
    chat = FactoryGirl.create(:user)

    g = FactoryGirl.create(:game, name: 'Game#1', id: 1)
    chat.own_games << g
    g.levels << FactoryGirl.create(:level, id: 1)
    g.levels.first.codes << FactoryGirl.create(:code)

    FactoryGirl.create(:game, name: 'Game#2', id: 2)

    @snd = SearchndrochBot.new

    allow(chat).to receive(:send_message) { |msg| msg[:text] }
    allow(@snd).to receive(:chat) { chat }
  end

  it 'should validate game_id' do
    # Game id is integer number greater than 0
    expect { @snd.send(:cmd_delete, '/delete text') }
      .to raise_error(SND::InvalidGameNumberError)
    expect { @snd.send(:cmd_delete, '/delete -5') }
      .to raise_error(SND::InvalidGameNumberError)
    expect { @snd.send(:cmd_delete, '/delete') }
      .to raise_error(SND::InvalidGameNumberError)
    expect { @snd.send(:cmd_delete, '/delete 0') }
      .to raise_error(SND::InvalidGameNumberError)

    # Game with given id should exist
    expect { @snd.send(:cmd_delete, '/delete 3') }
      .to raise_error(SND::DefunctGameNumberError)

    # Given game should belong to current user
    expect { @snd.send(:cmd_delete, '/delete 2') }
      .to raise_error(SND::GameOwnerError)
  end

  it 'should delete game' do
    expect(@snd.send(:cmd_delete, '/delete 1')).to eq 'Игра #1 удалена'
    expect(SND::Game.find_by_id(1)).to be_nil
    expect(SND::Level.where(game_id: 1)).to be_empty
    expect(SND::Code.where(level_id: 1)).to be_empty
  end
end
