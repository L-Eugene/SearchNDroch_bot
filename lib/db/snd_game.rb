# frozen_string_literal: true

require 'db/snd_base'
require 'db/snd_level'
require 'db/snd_game_player'

module SND
  # Game class
  class Game < SNDBase
    default_scope { order(start: :asc) }

    belongs_to :author, class_name: 'Chat', foreign_key: 'chat_id'

    has_many :levels, dependent: :destroy
    has_many :game_players, dependent: :destroy
    has_many :players, through: :game_players, source: :chat, before_add: :enforce_unique_players

    after_initialize { self.status ||= 'Future' }

    before_destroy { |g| raise SND::DeleteAfterStart unless g.status == 'Future' }

    validates_inclusion_of :status, in: %w[Running Over Future], message: 'Invalid game status'

    # @param [SND::Chat] chat
    # @return [Boolean]
    def authored_by?(chat)
      chat_id.nil? ? false : chat_id == chat.id
    end

    # @param [SND::Chat] chat
    # @return [Boolean]
    def played_by?(chat)
      players.exists? chat.id
    end

    # @param [Array] levels
    # @return [SND::Game]
    def create_levels(levels)
      tap { |game| levels.each { |level| game.levels << SND::Level.create_level(level) } }
    end

    def start!
      SND.log.debug "Starting game ##{id}"
      update!(status: 'Running')
      players.each do |player|
        SND::LevelTime.create(level: levels.first, chat: player, start_time: start, end_time: nil)

        player.send_message(text: SND.t.game.start(id: id))
        player.send_message(Tpl::Chat.menu.merge(Tpl::Level.task(levels.first, player)))
      end
    end

    # @return [Integer] seconds to game finish
    def finish_time
      start + levels.sum(&:duration).minutes
    end

    def finish!
      SND.log.debug " ++ Game finish operation for ##{id}"

      # Changing game status
      update!(status: 'Over')

      # Closing opened levels
      SND::LevelTime.gameover(self)

      # Sending message to players
      players.each do |player|
        SND.log.debug " +++ Send gameover message to #{player.name}(#{player.id})"
        player.send_message(Tpl::Chat.menu(false).merge(Tpl::Game.finish(self)))
      end
    end

    def level_up
      ts = Time.current

      players.each do |chat|
        while SND::LevelTime.timeout(self, ts).present?
          SND.log.debug do
            " ++ Game levelup operations for ##{SND::LevelTime.timeout(self, ts).pluck(:id).join(',')}"
          end

          SND::LevelTime.timeout(self, ts).each(&:level_up)
          chat.send_message(SND::Tpl::Chat.task(chat))
        end
      end
    end

    def check_pass(chat)
      return unless level(chat).codes_left(chat) <= 0

      SND::LevelTime.by_game_chat(self, chat).last.level_up(Time.current)
      chat.send_message(SND::Tpl::Chat.task(chat))
    end

    def warn_level_up
      SND::LevelTime.warn_levelup(self).each do |lt|
        SND.log.debug " ++ Game warn levelup operations for ##{lt.level_id}"
        lt.chat.send_message(
          text: SND.t.level.warn_level_up(lt.level.time_left_min(lt.chat))
        )
      end
    end

    # @param [SND::Chat] player
    # @param [Time] time
    # @return [SND::Level] if level is active
    # @return [NilClass] if no active level available
    # @raise [SND::GameNotRunning] if game status is not 'Running'
    def level(player, time = Time.current)
      raise SND::GameNotRunning if status != 'Running'

      SND::LevelTime.by_game_chat(self, player).reorder(level_id: :desc).find_by(
        '(:time >= start_time AND :time < end_time) OR (:time >= start_time AND end_time IS NULL)',
        time: time
      )&.level || raise(SND::GameOver, chat: player)
    end

    # @return [Hash]
    def stat
      players.map { |player| SND::Bonus.player_stat(player, self) }.sort_by { |a| [-1 * a[:bonus], a[:time]] }
    end

    # @param [String] time
    # @raise [SND::TimeInPastError] if given time is in past
    # @raise [SND::InvalidTimeFormat]
    def update_start(time)
      time = Time.parse(time)
      raise SND::TimeInPastError, chat: author if time <= Time.current

      update!(start: time)
    rescue ArgumentError
      raise SND::InvalidTimeFormat, chat: author
    end

    # @param [SND::Chat] player
    # @raise [SND::AlreadyJoinedError] if trying to attend game more than once
    def enforce_unique_players(player)
      raise SND::AlreadyJoinedError, chat: player if played_by? player
    end

    # @param [SND::Chat] chat
    # @param [Numeric] game_id
    # @param [Boolean] own
    # @return [SND::Game]
    # @raise [SND::InvalidGameNumberError] if given game id is non-positive or not a number
    # @raise [SND::DefunctGameNumberError] if game with given id is not exists
    # @raise [SND::GameOwnerError] if user asking for game is not it's owner.
    #   Only checked if own param is true
    def self.load_game(chat, game_id, own = false)
      raise SND::InvalidGameNumberError, chat: chat if game_id.to_i <= 0

      SND::Game.find_by_id(game_id).tap do |game|
        raise SND::DefunctGameNumberError, chat: chat if game.nil?
        raise SND::GameOwnerError, chat: chat if own && !game.authored_by?(chat)
      end
    end

    # @param [Hash] hash
    # @raise [ArgumentError] if given parameter is not a hash
    def self.create_game(hash)
      raise ArgumentError, 'Incorrect game hash' unless hash.is_a? Hash

      SNDBase.transaction { Game.create(hash.slice(:name, :description, :start)).create_levels(hash[:levels]) }
    end

    def self.start_games
      SND.log.debug ' + Game start operations'
      Game.where(start: Time.at(0)..Time.current.end_of_minute, status: 'Future').each(&:start!)
    end

    def self.game_operations
      SND.log.debug ' + Periodic game operations'

      ts = Time.current
      SND::Game.where(status: 'Running').each do |g|
        next g.finish! if g.finish_time <= ts

        g.level_up
        g.warn_level_up
      end
    end
  end
end
