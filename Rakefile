# frozen_string_literal: true

require_relative 'searchndroch_bot.rb'
require 'rspec/core/rake_task'

ActiveRecord::Base.establish_connection SND.cfg.options['database']

RSpec::Core::RakeTask.new

namespace :test do
  namespace :db do
    desc 'Initialize test database'
    task :init do
      FileUtils.rm(SND.cfg.options['database']['database'])
      ActiveRecord::Migrator.migrate('db/', nil)
    end
  end

  task run: ['db:prepare', :spec]
end
