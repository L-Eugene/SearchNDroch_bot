# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'db/snd_game'

describe SND::Game do
  before(:all) do
    @file_path = "#{File.dirname(__FILE__)}/../fixtures/game_create"
  end

  before(:each) do
    @game = SND::Game.create_game YAML.load_file("#{@file_path}/game.yml")

    @chat = FactoryGirl.create(:user)
    g = FactoryGirl.create(:game, name: 'Game#1', id: 10)
    @chat.own_games << g

    FactoryGirl.create(:game, name: 'Game#2', id: 20)

    @snd = SearchndrochBot.new

    allow(@chat).to receive(:send_message) { |msg| msg[:text] }
    allow(@snd).to receive(:chat) { @chat }
  end

  it 'should import game' do
    expect(@game.name).to eq 'SD#1'
    expect(@game.description).to eq 'Поисковая игра на одном объекте'
    expect(@game.start).to eq Time.parse('2020-07-01 00:00:00')
  end

  it 'should import levels' do
    expect(@game.levels.size).to eq 2
    expect(@game.levels.first.name).to eq 'Уровень 1'
    expect(@game.levels.first.task).to eq 'Найдите все 5 кодов.'
    expect(@game.levels.first.duration).to eq 15
    expect(@game.levels.first.to_pass).to eq 5

    expect(@game.levels.first.codes.size).to eq 5
  end

  it 'should validate game_id' do
    expect { SND::Game.load_own_game(@chat, '') }
      .to raise_error(SND::InvalidGameNumberError)
    expect { SND::Game.load_own_game(@chat, '0') }
      .to raise_error(SND::InvalidGameNumberError)
    expect { SND::Game.load_own_game(@chat, '-5') }
      .to raise_error(SND::InvalidGameNumberError)
    expect { SND::Game.load_own_game(@chat, 'text') }
      .to raise_error(SND::InvalidGameNumberError)

    expect { SND::Game.load_own_game(@chat, 2) }
      .to raise_error(SND::DefunctGameNumberError)

    expect { SND::Game.load_own_game(@chat, 1) }
      .to raise_error(SND::GameOwnerError)
  end

  it 'should link player to game only once' do
    before = @game.players.size
    @game.players << @chat
    expect { @game.players << @chat }.to raise_error(SND::AlreadyJoinedError)
    expect(@game.players.size).to eq before + 1
  end

  it 'should provide needed attributes' do
    expect(@game).to respond_to(:id)
    expect(@game).to respond_to(:name)
    expect(@game).to respond_to(:description)
    expect(@game).to respond_to(:allow_teams)
    expect(@game).to respond_to(:start)
    expect(@game).to respond_to(:author)
  end
end
