# frozen_string_literal: true

require 'db/snd_base'

module SND
  # Link players to games
  class GamePlayer < SNDBase
    belongs_to :chat
    belongs_to :game
  end
end
