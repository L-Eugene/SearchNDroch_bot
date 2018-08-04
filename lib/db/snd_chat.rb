# frozen_string_literal: true

require 'db/snd_base'
require 'db/snd_game_player'
require 'db/snd_bonus'

module SND
  # Chat class
  class Chat < SNDBase
    has_many :own_games, class_name: 'Game', after_add: :added_game
    has_many :bonuses
    has_many :game_players

    has_many :games, through: :game_players

    def send_message(options)
      raise ArgumentError, 'Parameter should be hash' unless options.is_a? Hash
      raise ArgumentError, 'Missing message text' unless options.key? :text
      SND.tlg.api.send_message(options.merge(chat_id: chat_id))
    rescue StandardError
      SND.log.error $ERROR_INFO.message
    end

    def games_print
      own_games.map { |g| "##{g.id}: [#{g.start}] #{g.name}" }
    end

    def task_print
      active_game.level.task_print(self)
    end

    def status_print
      active_game.level.status_print self
    end

    def finish_print(game = active_game)
      t.game.finish(results: stat_print(game), id: game.id)
    end

    def stat_print(game = active_game)
      game.stat.map
          .with_index { |row, id| "#{id + 1}. #{row[:name]} [#{row[:bonus]}]" }
          .unshift("[#{game.id}] #{game.name}").join("\n")
    end

    def info_print(game = active_game)
      game.info_print
    end

    def send_noprefix
      send_message(text: t.game.code.noprefix) if private?
    end

    def send_code(ucode, time)
      code = active_game.level(time).check_code(ucode)

      return code_msg(:invalid, ucode) unless code
      return code_msg(:double, ucode) if bonus?(code)

      create_bonus(code, time)
      "#{code_msg(:valid, ucode)}\n#{status_print}"
    end

    def create_bonus(code, time)
      code.bonuses << SND::Bonus.create(
        chat: self,
        code: code,
        time: time
      )
    end

    def bonus?(code)
      !code.bonuses.where(chat: id).empty?
    end

    def private?
      chat_id.to_i.positive?
    end

    def group?
      !private?
    end

    def added_game(game)
      send_message(text: t.create.success(id: game.id))
    end

    def self.identify(message)
      chat = Chat.find_or_create_by(chat_id: message.chat.id)
      chat.update_attribute(
        :name,
        "#{message.from.first_name} #{message.from.last_name}"
      )
      chat
    end

    def menu(show = true)
      return menu_add if show
      menu_remove
    end

    private

    def menu_add
      {
        reply_markup: Telegram::Bot::Types::ReplyKeyboardMarkup.new(
          keyboard: [['/info', '/task'], ['/stat', '/status', '/help']],
          resize_keyboard: true
        )
      }
    end

    def menu_remove
      {
        reply_markup: Telegram::Bot::Types::ReplyKeyboardRemove.new(
          remove_keyboard: true
        )
      }
    end

    def active_game
      game = games.where(status: 'Running').first
      raise SND::GameNotRunning if game.nil?
      game
    end

    def code_msg(name, code)
      t.game.code.send(name.to_sym, code: code)
    end
  end
end
