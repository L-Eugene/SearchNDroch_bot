# frozen_string_literal: true

module SND
  # Chat /task command processor
  module ChatCommand
    def cmd_task(_args)
      chat.send_message(Tpl::Chat.task(chat))
    end
  end
end
