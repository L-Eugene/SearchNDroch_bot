# frozen_string_literal: true

require 'active_record'

namespace :snd do
  namespace :db do
    task :initdb do
      ActiveRecord::Base.establish_connection SND.cfg.options['database']

      ActiveRecord::Tasks::DatabaseTasks.db_dir = '.'
      ActiveRecord::Tasks::DatabaseTasks.migrations_paths = "#{SND.cfg.options['libdir']}/../db/"

      ActiveRecord::Migrator.migrations_paths = ActiveRecord::Tasks::DatabaseTasks.migrations_paths
    end

    desc 'Retrieves the current schema version number'
    task version: :initdb do
      db_name = ActiveRecord::Base.connection.try(:current_database) || SND.cfg.options['database'][:database]
      puts "Current version of `#{db_name}`: #{ActiveRecord::Base.connection.migration_context.current_version}"
    end

    desc 'Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog).'
    task migrate: :initdb do
      ActiveRecord::Tasks::DatabaseTasks.migrate
    end

    namespace :migrate do
      desc 'Display status of migrations'
      task status: :initdb do
        abort 'Schema migrations table does not exist yet.' unless ActiveRecord::SchemaMigration.table_exists?

        puts "\ndatabase: #{ActiveRecord::Base.connection_config[:database]}\n\n"
        puts "#{'Status'.center(8)}  #{'Migration ID'.ljust(14)}  Migration Name"
        puts '-' * 50
        ActiveRecord::Base.connection.migration_context.migrations_status.each do |status, version, name|
          puts "#{status.center(8)}  #{version.ljust(14)}  #{name}"
        end
        puts
      end
    end

    desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
    task rollback: :initdb do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      ActiveRecord::Base.connection.migration_context.rollback(step)
    end
  end
end
