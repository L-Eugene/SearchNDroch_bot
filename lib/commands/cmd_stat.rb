# frozen_string_literal: true

module SND
  # Chat /stat command processor
  module ChatCommand
    def cmd_stat(args)
      return chat.send_message(text: chat.stat_print) if args.empty?

      game = SND::Game.load_game(chat, args.shift)
      chat.send_message(text: chat.stat_print(game))
    end
  end
end
