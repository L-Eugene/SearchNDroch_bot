# frozen_string_literal: true

require 'db/snd_base'

module SND
  # Code monitoring storage
  class Monitoring < SNDBase
    belongs_to :chat
    belongs_to :level
    belongs_to :code, optional: true

    scope :valid, -> { where.not code: nil }
    scope :invalid, -> { where code: nil }
  end
end
