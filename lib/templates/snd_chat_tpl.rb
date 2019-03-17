# frozen_string_literal: true

require 'will_paginate/array'

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
      def self.games(chat = nil)
        # if chat is not defined - show all future or running games
        (chat&.own_games || SND::Game.where(status: %w[Future Running]))
          .map { |g| "#{SND.t.game.icon status: g.status} ##{g.id}: [#{g.start}] #{g.name}" }
      end

      # @param [SND::Chat] chat
      # @return [Hash] Telegram Bot message hash
      def self.task(chat, level = nil)
        Tpl::Level.task(level || chat.active_game.level(chat), chat)
      rescue SND::GameOver
        Tpl::Game.no_levels_left
      end

      def self.keyboard_button(text, callback)
        { text: text, callback_data: callback }
      end

      # @param [String] command command to send on button click
      # @param [Fixnum] size game list size
      # @param [Fixnum] page current page
      # @return [Telegram::Bot::Types::InlineKeyboardMarkup]
      def self.keyboard(command, size, page)
        pages = (size.to_f / 10).ceil
        Telegram::Bot::Types::InlineKeyboardMarkup.new.tap do |result|
          keyboard = []

          keyboard << keyboard_button('<', "/#{command} #{page - 1}") if page > 1
          keyboard << keyboard_button('>', "/#{command} #{page + 1}") if pages > page

          result.inline_keyboard = [keyboard]
        end
      end

      # @param [SND::Chat] chat
      # @param [Fixnum] page
      # @return [Hash] Telegram Bot message hash
      def self.list(chat, page = 1)
        list = games(chat)
        return { text: SND.t.list.nogames } if list.empty?

        {
          text: SND.t.list.games(list: list.paginate(per_page: 10, page: page).join("\n")),
          reply_markup: keyboard('list', list.size, page)
        }
      end

      # @param [Fixnum] page
      # @return [Hash] Telegram Bot message hash
      def self.calendar(page = 1)
        list = games
        return { text: SND.t.cal.nogames } if list.empty?

        {
          text: SND.t.cal.games(list: list.paginate(per_page: 10, page: page).join("\n")),
          reply_markup: keyboard('cal', list.size, page)
        }
      end
    end
  end
end
