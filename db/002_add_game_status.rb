# frozen_string_literal: true

# Migrate #1
class AddGameStatus < ActiveRecord::Migration[4.2]
  def self.up
    add_column :games, :status, :string
  end

  def self.down
    remove_column :games, :status, :string
  end
end
