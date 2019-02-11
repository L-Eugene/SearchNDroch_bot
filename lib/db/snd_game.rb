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
      update!(status: 'Running')
      players.each do |player|
        player.send_message(text: SND.t.game.start(id: id))
        player.send_message(Tpl::Chat.menu.merge(Tpl::Level.task(level, player)))
      end
    end

    # @return [Integer] seconds to game finish
    def finish_time
      start + levels.sum(&:duration).minutes
    end

    def finish!
      update!(status: 'Over')
      players.each do |player|
        player.send_message(Tpl::Chat.menu(false).merge(Tpl::Game.finish(self)))
      end
    end

    def level_up!
      players.each { |player| player.send_message(level.task_print(player)) }
    end

    def warn_level_up!(time)
      players.each { |player| player.send_message(text: SND.t.level.warn_level_up(time)) }
    end

    # @param [Time] time
    # @return [SND::Level] if level is active
    # @return [NilClass] if no active level available
    # @raise [SND::GameNotRunning] if game status is not 'Running'
    def level(time = Time.now)
      raise SND::GameNotRunning if status != 'Running'

      levels.inject(start) do |tm, level|
        return level if tm + level.duration.minutes > time

        tm + level.duration.minutes
      end
      nil
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
      raise SND::TimeInPastError, chat: author if time <= Time.now

      update!(start: time)
    rescue ArgumentError
      raise SND::InvalidTimeFormat, chat: author
    end

    # @param [SND::Chat] player
    # @raise [SND::AlreadyJoinedError] if trying to attend game more than once
    def enforce_unique_players(player)
      raise SND::AlreadyJoinedError, chat: player if played_by? player
    end

    # @param [SND::Level] level
    # @return [Numeric] seconds left to given level
    def time_to_level(level)
      levels.take_while { |l| l.id != level.id }.sum(&:duration)
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
      ts = Time.now
      Game.where(start: ts.beginning_of_minute..ts.end_of_minute).each { |g| g.start! if g.status == 'Future' }
    end

    def self.game_operations
      ts = Time.now
      SND::Game.where(status: 'Running').each do |g|
        next g.finish! if g.finish_time <= ts

        min_left = Time.at(g.level.time_left_sec).strftime('%M').to_i
        next g.warn_level_up! min_left if [4, 0].include? min_left

        g.level_up! if g.level != g.level(Time.now - 1.minute)
      end
    end
  end
end
