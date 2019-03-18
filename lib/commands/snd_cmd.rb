# frozen_string_literal: true

module SND
  # Chat command processor
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

    # @param [Array] args
    def cmd_delete(args)
      game_id = args.shift.to_i

      SND::Game.load_game(chat, game_id, true).destroy

      chat.send_message(text: SND.t.delete.success(id: game_id))
    end

    # @param [Array] _args
    def cmd_help(_args)
      chat.send_message(text: SND.t.help)
    end

    # @param [Array] args
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

    # @param [Array] args
    def cmd_join(args)
      game = SND::Game.load_game(chat, args.shift)
      game.players << chat
      chat.send_message text: SND.t.join.success(id: game.id)
    end

    # @param [Array] args
    def cmd_list(args)
      page = (args.shift || 1).to_i
      message = args.shift

      return chat.send_message(Tpl::Chat.list(chat, page)) unless message

      chat.send_message(
        Tpl::Chat.list(chat, page).merge(message_id: message),
        :edit_message_text
      )
    end

    # @param [Array] args
    def cmd_move_start(args)
      game = SND::Game.load_game(chat, args.shift, true)
      game.update_start(args.join(' '))

      chat.send_message(
        text: SND.t.move_start.success(
          id: game.id,
          start: SND.l(game.start, '%F %T %z')
        )
      )
    end

    # @param [Array] args
    def cmd_name(args)
      raise SND::NoParametersGiven if args.empty?

      chat.update!(name: args.join(' '))
      chat.send_message(text: SND.t.name.success(name: chat.name))
    end

    def cmd_stat(args)
      game = args.empty? ? chat.active_game : SND::Game.load_game(chat, args.shift)
      chat.send_message(text: Tpl::Game.stat(game))
    end

    def cmd_status(_args)
      chat.send_message(text: chat.status_message)
    end

    def cmd_task(_args)
      chat.send_message(Tpl::Chat.task(chat))
    end

    alias cmd_calendar cmd_cal
  end
end
