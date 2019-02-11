# frozen_string_literal: true

require 'db/snd_base'

module SND
  # Code class
  class Code < SNDBase
    belongs_to :level

    has_many :bonuses, class_name: 'Bonus'

    scope :closed, ->(chat_id) { joins(:bonuses).where(bonuses: { chat: chat_id }) }
  end
end
