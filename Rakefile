# frozen_string_literal: true

require_relative 'searchndroch_bot.rb'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new
RuboCop::RakeTask.new

Dir.glob('lib/rake/*.rake').each { |f| import f }

task default: [:rubocop, 'snd:db:migrate', :spec]
