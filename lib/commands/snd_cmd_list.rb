# frozen_string_literal: true

module SND
  # Chat /list command processor
  module ChatCommand
    def cmd_list(_args)
      games = Tpl::Chat.games(chat)
      return chat.send_message(text: SND.t.list.nogames) if games.empty?

      chat.send_message(text: SND.t.list.games(list: games.join("\n")))
    end
  end
end
