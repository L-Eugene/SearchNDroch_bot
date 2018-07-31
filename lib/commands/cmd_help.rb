# frozen_string_literal: true

module SND
  # Chat /help command processor
  module ChatCommand
    def cmd_help(_args)
      chat.send_message(text: t.help)
    end
  end
end
