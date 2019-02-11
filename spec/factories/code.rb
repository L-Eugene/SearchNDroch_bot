# frozen_string_literal: true

require 'db/snd_game'

FactoryBot.define do
  factory :code, class: SND::Code do
    bonus { 1 }
  end
end
