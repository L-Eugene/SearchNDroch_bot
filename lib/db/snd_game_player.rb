# frozen_string_literal: true

require 'db/snd_base'

module SND
  # Link players to games
  class GamePlayer < SNDBase
    belongs_to :chat
    belongs_to :game

    before_save :create_leveltime, if: :new_record?

    def create_leveltime
      return unless game.status == 'Running'

      time = Time.now
      game.levels.inject(game.start) do |tm, level|
        if tm + level.duration.minutes > time
          SND::LevelTime.create(level: level, start_time: tm, chat: chat)
          break
        end

        tm + level.duration.minutes
      end
    end

    scope :by_game, ->(game) { where(game: game) }
    scope :by_chat, ->(chat) { where(chat: chat) }
  end
end
