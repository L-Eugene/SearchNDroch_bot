# frozen_string_literal: true

require 'db/snd_base'

module SND
  # Code class
  class Code < SNDBase
    belongs_to :level
    belongs_to :parent, class_name: :Code, foreign_key: :main

    has_many :bonuses, class_name: 'Bonus'

    after_save { |instance| instance.update_attribute(:main, instance.id) unless instance.main }

    scope :closed, ->(chat_id) { joins(:bonuses).where('bonuses.chat_id = ? and codes.main = codes.id', [chat_id]) }
  end
end
