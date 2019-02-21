# frozen_string_literal: true

# Migrate #5
class RenameValueHashToValue < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :codes, :value_hash, :value
  end

  def self.down
    rename_column :codes, :value, :value_hash
  end
end
