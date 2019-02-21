# frozen_string_literal: true

# Migrate #6
class AddMainCodeColumn < ActiveRecord::Migration[4.2]
  def self.up
    add_column :codes, :main, :integer
  end

  def self.down
    remove_column :codes, :main, :integer
  end
end
