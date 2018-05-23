# frozen_string_literal: true

require 'db/snd_base'

module SND
  # Code class
  class Code < SNDBase
    belongs_to :level

    has_many :bonuses
  end
end
