# frozen_string_literal: true

module SND
  # Chat /info command processor
  module ChatCommand
    def cmd_info(args)
      return chat.send_message(text: chat.info_print) if args.empty?

      chat.send_message(
        text: chat.info_print(SND::Game.load_game(chat, args.shift))
      )
    end
  end
end
