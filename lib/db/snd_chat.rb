# frozen_string_literal: true

require 'r18n/snd_r18n'
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

    # @param [Hash] options
    # @param [Symbol] method
    # @raise [ArgumentError] if options is not a hash with :text key
    def send_message(options, method = :send_message)
      raise ArgumentError, 'Parameter should be hash' unless options.is_a? Hash
      raise ArgumentError, 'Missing message text' unless options.key? :text

      options[:text] = options[:text].to_s

      SND.log.debug options.merge(chat_id: chat_id)
      SND.tlg.api.__send__(method, options.merge(chat_id: chat_id))
    rescue StandardError
      SND.log.error "#{$ERROR_INFO.message}\n#{$ERROR_INFO.backtrace.join("\n")}"
    end

    # @param [String] ucode
    # @param [Time] time
    # @return [String] response text for user
    def send_code(ucode, time)
      code = active_game.level(time).check_code(ucode)

      SND::Monitoring.create(value: ucode, time: time, level: active_game.level(time), chat: self, code: code)

      return code_msg(:invalid, ucode) unless code
      return code_msg(:double, ucode) if bonus?(code)

      code.bonuses << SND::Bonus.create(chat: self, code: code, time: time)
      "#{code_msg(:valid, ucode)}\n#{status_message}"
    end

    # @return [Boolean]
    # Checks if user already completed this code
    def bonus?(code)
      code.bonuses.where(chat: id).present?
    end

    # @return [Boolean]
    # True if it is a private chat
    def private?
      chat_id.to_i.positive?
    end

    # @return [Boolean]
    # True if it is a group
    def group?
      !private?
    end

    # @return [SND::Chat]
    def self.identify(message)
      Chat.find_or_create_by(chat_id: message.chat.id).tap do |chat|
        return chat if chat.name

        chat.update!(name: "#{message.from.first_name} #{message.from.last_name}")
      end
    end

    # @return [SND::Game]
    # @raise [SND::GameNotRunning] if user not attended any active game
    def active_game
      games.where(status: 'Running').first || raise(SND::GameNotRunning)
    end

    # @return [String]
    def status_message
      result = active_game.level.chat_stat(id)
      result[:left].empty? ? SND.t.game.code.alldone : SND.t.game.status(result)
    end

    # @param [SND::Game] game
    def added_game(game)
      send_message(text: SND.t.create.success(id: game.id))
    end

    # @param [Symbol] name
    # @param [String] code
    # @return [String]
    def code_msg(name, code)
      SND.t.game.code.__send__(name.to_sym, code: code)
    end

    private :added_game, :code_msg
  end
end
