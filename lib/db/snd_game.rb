# frozen_string_literal: true

require 'db/snd_base'
require 'db/snd_level'
require 'db/snd_game_player'

module SND
  # Game class
  class Game < SNDBase
    belongs_to :author, class_name: 'Chat', foreign_key: 'chat_id'
    has_many :levels, dependent: :destroy
    has_many :game_players, dependent: :destroy

    has_many :players, through: :game_players, source: :chat,
                       before_add: :enforce_unique_players

    before_destroy { |g| raise SND::DeleteAfterStart unless g.status.nil? }

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
        player.send_message(player.menu.merge(level.task_print(player)))
      end
    end

    def finish
      start + levels.sum(&:duration).minutes
    end

    def finish!
      update_attribute(:status, 'Over')
      players.each do |player|
        player.send_message(
          player.menu(false).merge(text: player.finish_print(self))
        )
      end
    end

    def level_up!
      players.each { |player| player.send_message(level.task_print(player)) }
    end

    def warn_level_up!(time)
      players.each do |player|
        player.send_message(text: t.level.warn_level_up(time))
      end
    end

    def level(time = Time.now)
      raise SND::GameNotRunning if status != 'Running'
      result = levels.inject(start) do |t, l|
        return l if t + l.duration.minutes > time
        t + l.duration.minutes
      end
      return nil unless result.is_a? SND::Level
    end

    def info_print
      {
        text: t.game.info(
          id: id,
          name: name,
          description: description,
          game_status: t.game.starts(time: l(start, '%F %T %z'), status: status)
        ),
        parse_mode: 'HTML'
      }
    end

    def stat
      players.map { |player| SND::Bonus.player_stat(player, self) }
             .sort_by { |a| [-1 * a[:bonus], a[:time]] }
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

    def minutes_until(level)
      levels.take_while { |e| e.id != level.id }.sum(&:duration)
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
