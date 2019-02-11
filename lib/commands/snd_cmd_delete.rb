# frozen_string_literal: true

module SND
  # Chat /delete command processor
  module ChatCommand
    def cmd_delete(args)
      game_id = args.shift.to_i

      SND::Game.load_game(chat, game_id, true).destroy

      chat.send_message(text: SND.t.delete.success(id: game_id))
    end
  end
end
