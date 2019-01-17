# frozen_string_literal: true

namespace :snd do
  desc 'Run console with bot environment loaded'
  task :console do
    require 'irb'
    require 'irb/completion'

    ARGV.clear
    IRB.start
  end
end
