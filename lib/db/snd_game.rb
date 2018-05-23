# frozen_string_literal: true

require 'db/snd_base'
require 'db/snd_level'
require 'db/snd_game_player'

module SND
  # Game class
  class Game < SNDBase
    belongs_to :author, class_name: 'Chat', foreign_key: 'chat_id'
    has_many :levels, dependent: :destroy
    has_many :game_players

    has_many :players, through: :game_players, source: :chat,
                       before_add: :enforce_unique_players

    def authored_by?(chat)
      return false if chat_id.nil?
      chat_id == chat.id
    end

    def played_by?(chat)
      players.exists? chat.id
    end

    def create_levels(levels)
      levels.each do |level|
        self.levels << SND::Level.create_level(level)
      end
      self
    end

    def update_start(time)
      begin
        time = Time.parse(time)
      rescue ArgumentError
        raise SND::InvalidTimeFormat, chat: author
      end
      raise SND::TimeInPastError, chat: author if time <= Time.now

      update_attribute(:start, time)
    end

    def enforce_unique_players(player)
      raise AlreadyJoinedError, chat: player if played_by? player
    end

    def self.load_game(chat, game_id)
      game_id = game_id.to_i
      raise SND::InvalidGameNumberError, chat: chat if game_id <= 0

      game = SND::Game.find_by_id(game_id)

      raise SND::DefunctGameNumberError, chat: chat if game.nil?
      game
    end

    def self.load_own_game(chat, game_id)
      game = load_game(chat, game_id)
      raise SND::GameOwnerError unless game.authored_by? chat

      game
    end

    def self.create_game(hash)
      raise ArgumentError, 'Incorrect game hash' unless hash.is_a? Hash
      game = Game.create(
        name: hash[:name],
        description: hash[:description],
        start: hash[:start]
      )
      game.create_levels(hash[:levels])
    end
  end
end
