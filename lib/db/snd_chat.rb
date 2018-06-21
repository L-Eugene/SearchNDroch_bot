# frozen_string_literal: true

require 'db/snd_base'
require 'db/snd_game_player'

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
      active_game.level.task
    end

    def status_print
      active_game.level.status_print self
    end

    def stat_print
      active_game.stat
                 .sort_by { |a| [-1 * a[:bonus], a[:time]] }
                 .map.with_index do |row, id|
        "#{id + 1}. #{row[:name]} [#{row[:bonus]}]"
      end.join("\n")
    end

    def info_print
      active_game.info_print
    end

    def send_code(ucode, time)
      code = active_game.level(time).check_code(ucode)

      return code_msg(:invalid, ucode) unless code
      return code_msg(:double, ucode) if bonus?(code)

      create_bonus(code, time)
      code_msg(:valid, ucode)
    end

    def create_bonus(code, time)
      code.bonuses << SND::Bonus.create(
        chat: self,
        code: code,
        time: time
      )
    end

    def bonus?(code)
      !code.bonuses.where(code: code).empty?
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

    private

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
