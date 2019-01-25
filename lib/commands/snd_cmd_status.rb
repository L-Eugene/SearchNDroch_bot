# frozen_string_literal: true

module SND
  # Chat /status command processor
  module ChatCommand
    def cmd_status(_args)
      chat.send_message text: chat.status_print
    end
  end
end
