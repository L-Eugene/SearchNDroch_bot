# frozen_string_literal: true

module SND
  # Chat /list command processor
  module ChatCommand
    def cmd_code(msg)
      return if %r{^\/}.match? msg

      unless %r{^!}.match? msg
        raise InvalidCodeFormat if chat.private?

        return
      end

      chat.send_message(text: chat.send_code(Unicode.downcase(msg[1..-1]).strip, @time))
    end
  end
end
