# frozen_string_literal: true

module SND
  # Chat /cal command processor
  module ChatCommand
    # @param [Array] args
    def cmd_cal(args)
      page = (args.shift || 1).to_i
      message = args.shift

      return chat.send_message(Tpl::Chat.calendar(page)) unless message

      chat.send_message(
        Tpl::Chat.calendar(page).merge(message_id: message),
        :edit_message_text
      )
    end

    alias cmd_calendar cmd_cal
  end
end
