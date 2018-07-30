# frozen_string_literal: true

module SND
  # Chat /delete command processor
  module ChatCommand
    def cmd_delete(args)
      game_id = args.shift.to_i

      SND::Game.load_own_game(chat, game_id).destroy

      chat.send_message(text: t.delete.success(id: game_id))
    end
  end
end
