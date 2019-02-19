# frozen_string_literal: true

# Migrate #4
class CreateMonitoringTable < ActiveRecord::Migration[4.2]
  def self.up
    create_table :monitorings do |t|
      t.string :value
      t.timestamp :time

      t.belongs_to :level
      t.belongs_to :chat
      t.belongs_to :code
    end
  end

  def self.down
    drop_table :monitoring
  end
end
