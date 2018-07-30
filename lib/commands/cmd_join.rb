# frozen_string_literal: true

module SND
  # Chat /join command processor
  module ChatCommand
    def cmd_join(args)
      game = SND::Game.load_game(chat, args.shift)
      game.players << chat
      chat.send_message text: t.join.success(id: game.id)
    end
  end
end
