# frozen_string_literal: true

require 'db/snd_base'
require 'db/snd_code'

module SND
  # Level class
  class Level < SNDBase
    belongs_to :game
    has_many :codes, dependent: :destroy

    def self.create_level(hash)
      level = Level.create(
        name: hash[:name],
        task: hash[:task],
        duration: hash[:duration],
        to_pass: hash[:to_pass]
      )

      hash[:codes].each do |c|
        level.codes << Code.create(value_hash: c[:code], bonus: c[:bonus])
      end

      level
    end
  end
end
