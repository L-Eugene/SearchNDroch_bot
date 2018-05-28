# frozen_string_literal: true

require_relative 'searchndroch_bot.rb'
require 'rspec/core/rake_task'
require 'active_record'

include ActiveRecord::Tasks
DatabaseTasks.env = :development
DatabaseTasks.db_dir = './'
DatabaseTasks.migrations_paths = 'db'

DatabaseTasks.database_configuration = SND.cfg.options['database']

RSpec::Core::RakeTask.new

task :environment do
  ActiveRecord::Base.establish_connection SND.cfg.options['database']
end

namespace :test do
  load 'active_record/railties/databases.rake'

  task run: ['db:prepare', :spec]
end
