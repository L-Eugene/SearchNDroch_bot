# frozen_string_literal: true

# Search'N'Droch bot module
module SND
  module Tpl
    # Templates related to SND::Chat class
    module Chat
      # @param [Boolean] show show or hide menu
      # @return [Hash] Telegram Bot message hash
      # Template to add game menu
      def self.menu(show = true)
        if show
          {
            reply_markup: Telegram::Bot::Types::ReplyKeyboardMarkup.new(
              keyboard: [['/info', '/task'], ['/stat', '/status', '/help']],
              resize_keyboard: true
            )
          }
        else
          { reply_markup: Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true) }
        end
      end

      # @param [SND::Chat] chat
      # @return [Array] List of strings, each describes one game
      def self.games(chat)
        chat.own_games.map { |g| "#{SND.t.game.icon status: g.status} ##{g.id}: [#{g.start}] #{g.name}" }
      end

      # @param [SND::Chat] chat
      # @return [Hash] Telegram Bot message hash
      def self.task(chat)
        level = chat.active_game.level
        Tpl::Level.task(level, chat)
      end
    end
  end
end