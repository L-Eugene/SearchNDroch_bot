# frozen_string_literal: true

namespace :snd do
  namespace :db do
    ActiveRecord::Base.establish_connection SND.cfg.options['database']

    desc 'Migrate the database'
    task :migrate do
      ActiveRecord::Migrator.migrate('searchndroch_bot/db/', nil)
    end

    desc 'Rollback migration'
    task :rollback do
      ActiveRecord::Migrator.rollback('searchndroch_bot/db/')
    end
  end
end
