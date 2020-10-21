# frozen_string_literal: true

module SND
  # Chat code processor
  module ChatCommand
    def cmd_code(msg)
      return if %r{^/}.match? msg

      unless %r{^!}.match? msg
        raise InvalidCodeFormat, chat: chat if chat.private?

        return
      end

      result = chat.send_message(text: chat.send_code(Unicode.downcase(msg[1..-1]).strip, @time))
      chat.active_game.check_pass(chat)

      # Need to return this value for testing purpose
      result
    end
  end
end
