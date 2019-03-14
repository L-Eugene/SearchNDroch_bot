# frozen_string_literal: true

# Migrate #7
class CreateLevelTimeTable < ActiveRecord::Migration[4.2]
  def self.up
    create_table :level_times do |t|
      t.timestamp :start_time
      t.timestamp :end_time

      t.belongs_to :level
      t.belongs_to :chat
    end
  end

  def self.down
    drop_table :level_times
  end
end
