# frozen_string_literal: true

module SND
  # Chat /info command processor
  module ChatCommand
    def cmd_info(args)
      game = args.empty? ? chat.active_game : SND::Game.load_game(chat, args.shift)

      chat.send_message(
        text: SND.t.game.info(
          game.attributes.symbolize_keys.slice(:id, :name, :description).merge(
            game_status: SND.t.game.starts(time: SND.l(game.start, '%F %T %z'), status: game.status)
          )
        ),
        parse_mode: 'HTML'
      )
    end
  end
end
