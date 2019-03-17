# frozen_string_literal: true

# Search'N'Droch bot module
module SND
  module Tpl
    # Templates related to SND::Game class
    module Game
      # @param [SND::Game] game
      # @return [String] Stat message text
      def self.stat(game)
        game.stat.map
            .with_index do |row, id|
              "#{id + 1}. #{row[:name]} [#{row[:bonus]}] (#{SND.l(row[:time].localtime, '%d.%m %H:%M:%S')})"
            end
            .unshift("[#{game.id}] #{game.name}").join("\n")
      end

      # @param [SND::Game] game
      # @return [Hash] Telegram Bot message hash
      def self.finish(game)
        { text: t.game.finish(results: stat(game), id: game.id) }
      end

      def self.no_levels_left
        { text: t.error.game_over.msg }
      end
    end
  end
end
