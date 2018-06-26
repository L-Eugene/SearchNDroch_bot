# frozen_string_literal: true

namespace :snd do
  ActiveRecord::Base.establish_connection SND.cfg.options['database']

  DatabaseTasks.db_dir = '.'
  DatabaseTasks.migrations_paths = "#{SND.cfg.options['libdir']}../db/"

  load 'active_record/railties/databases.rake'
end
