# frozen_string_literal: true

# Migrate #3
class ChangeLevelTaskDatatype < ActiveRecord::Migration[4.2]
  def self.up
    change_column :levels, :task, :text
  end

  def self.down
    change_column :levels, :task, :string
  end
end
