# frozen_string_literal: true

module SND
  # Chat /move_start command processor
  module ChatCommand
    def cmd_move_start(args)
      game = SND::Game.load_own_game(chat, args.shift)
      game.update_start(args.join(' '))

      chat.send_message(
        text: SND.t.move_start.success(
          id: game.id,
          start: SND.l(game.start, '%F %T %z')
        )
      )
    end
  end
end
