# frozen_string_literal: true

namespace :snd do
  ActiveRecord::Base.establish_connection SND.cfg.options['database']

  p  "#{SND.cfg.options['libdir']}../"

  DatabaseTasks.db_dir = "."
  DatabaseTasks.migrations_paths = "#{SND.cfg.options['libdir']}../db/"

  load 'active_record/railties/databases.rake'
#  namespace :db do
#    ActiveRecord::Base.establish_connection SND.cfg.options['database']

#    desc 'Migrate the database'
#    task :migrate do
#      ActiveRecord::Migrator.migrate('searchndroch_bot/db/', nil)
#    end

#    desc 'Rollback migration'
#    task :rollback do
#      ActiveRecord::Migrator.rollback('searchndroch_bot/db/')
#    end
#  end
end
