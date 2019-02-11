# frozen_string_literal: true

require 'db/snd_base'

module SND
  # Bonus class
  class Bonus < SNDBase
    self.table_name = 'bonuses'
    belongs_to :code
    belongs_to :chat

    # @param [SND::Chat] player
    # @param [SND::Game] game
    # @return [Hash]
    def self.player_stat(player, game)
      b = Bonus.joins(:code).where(
        chat: player.id,
        code: game.levels.map { |level| level.codes.map(&:id) }.flatten
      )
      { name: player.name, bonus: b.sum(:bonus), time: b.maximum(:time) || game.start }
    end
  end
end
