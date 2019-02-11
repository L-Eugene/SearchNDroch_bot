# frozen_string_literal: true

module SND
  # Chat /stat command processor
  module ChatCommand
    def cmd_stat(args)
      game = args.empty? ? chat.active_game : SND::Game.load_game(chat, args.shift)
      chat.send_message(text: Tpl::Game.stat(game))
    end
  end
end
