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

    def start!
      update_attribute(:status, 'Running')
      players.each do |player|
        player.send_message(text: t.game.start(id: id))
        player.send_message(text: level.task)
      end
    end

    def finish
      start + levels.sum(&:duration).minutes
    end

    def finish!
      update_attribute(:status, 'Over')
      players.each do |player|
        player.send_message(text: t.game.finish(id: id))
      end
    end

    def level
      raise SND::GameNotRunning if status != 'Running'
      levels.inject(start) do |time, l|
        return l if time + l.duration.minutes > Time.now
        time + l.duration.minutes
      end
    end

    def info_print
      <<-RES
        [#{id}] #{name}
        #{description}
        #{t.game.starts(time: l(start, '%F %T %z'))}
      RES
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

    def self.start_games
      ts = Time.now
      time = [ts.beginning_of_minute, ts.end_of_minute]
      SND::Game.where(start: time.first..time.last).each do |g|
        next unless g.status.nil?
        g.start!
      end
    end

    def self.finish_games
      ts = Time.now
      SND::Game.where(status: 'Running').each do |g|
        next unless g.finish <= ts
        g.finish!
      end
    end
  end
end
