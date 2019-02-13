# frozen_string_literal: true

module SND
  # Chat /list command processor
  module ChatCommand
    # @param [Array] args
    def cmd_list(args)
      page = args.shift || 1
      message = args.shift.to_i

      return chat.send_message(Tpl::Chat.list(chat, page)) unless message

      chat.send_message(
        Tpl::Chat.list(chat, page).merge(message_id: message),
        :edit_message_text
      )
    end
  end
end
