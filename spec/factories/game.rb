# frozen_string_literal: true

require 'db/snd_game'

FactoryBot.define do
  factory :game, class: SND::Game do
    status { 'Future' }
  end
end
