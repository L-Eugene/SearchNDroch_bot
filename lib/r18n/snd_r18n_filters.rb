# frozen_string_literal: true

require 'r18n-core'
require 'r18n-rails-api'

R18n::Filters.on(:named_variables)
R18n::Filters.add('snd_gamestate') do |translate, _config, hash|
  case hash[:status]
  when 'Over'
    translate['passed']
  when 'Running'
    translate['active']
  else
    translate['future']
  end
end

R18n::Filters.add('snd_gamestate_icon') do |translate, _config, hash|
  next translate unless translate.is_a? Hash

  case hash[:status]
  when 'Over'
    translate['passed']
  when 'Running'
    translate['active']
  else
    translate['future']
  end
end
