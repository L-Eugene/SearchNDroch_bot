# frozen_string_literal: true

# Search'N'Droch bot module
module SND
  module Tpl
    # Templates related to SND::Level class
    module Level
      # @param [SND::Level] level
      # @param [SND::Chat] chat
      # @return [Hash] Telegram Bot message hash
      def self.task(level, chat)
        {
          text: SND.t.level.task(
            name: level.name,
            task: level.task,
            time: level.time_left(chat.id)
          ),
          parse_mode: 'HTML'
        }
      end
    end
  end
end
