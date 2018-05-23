# frozen_string_literal: true

require 'db/snd_base'

module SND
  # Bonus class
  class Bonus < SNDBase
    self.table_name = 'bonuses'
    belongs_to :code
    belongs_to :chat
  end
end
