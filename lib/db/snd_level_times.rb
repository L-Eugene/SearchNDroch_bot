# frozen_string_literal: true

require 'db/snd_base'

module SND
  # Level time period for players
  class LevelTime < SNDBase
    belongs_to :level
    belongs_to :chat

    scope :by_game_chat, ->(game, chat) { where(level_id: game.level_ids, chat: chat).order(level_id: :asc) }

    def self.timeout(game, time)
      ids = joins(:level).where(level_id: game.level_ids, end_time: nil).map do |lt|
        lt.id if lt.start_time + lt.level.duration.minutes <= time
      end.compact

      where(id: ids)
    end

    def self.warn_levelup(game)
      ids = joins(:level, :chat).where(level_id: game.level_ids, end_time: nil).map do |lt|
        lt.id if [1, 5].include? lt.level.time_left_min(lt.chat)
      end.compact

      where(id: ids)
    end

    def self.gameover(game)
      where(level_id: game.level_ids, end_time: nil).each { |lt| lt.update!(end_time: Time.current) }
    end

    def level_up(time = start_time + level.duration.minutes)
      update(end_time: time)

      return unless level.next_level

      LevelTime.create(chat: chat, level: level.next_level, start_time: time, end_time: nil)
    end
  end
end
