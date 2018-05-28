# frozen_string_literal: true

# Migrate #1
class CreateDatabase < ActiveRecord::Migration[4.2]
  def create_chats
    create_table :chats do |t|
      t.string :chat_id
      t.string :name
    end
  end

  def create_games
    create_table :games do |t|
      t.string :name
      t.string :description
      t.boolean :allow_teams
      t.timestamp :start

      t.belongs_to :chat
    end
  end

  def create_codes
    create_table :codes do |t|
      t.string :value_hash
      t.integer :bonus
      t.belongs_to :level, index: true
    end
  end

  def create_bonuses
    create_table :bonuses do |t|
      t.timestamp :time

      t.belongs_to :code, index: true
      t.belongs_to :chat, index: true
    end
  end

  def create_levels
    create_table :levels do |t|
      t.string :name
      t.string :task
      t.integer :duration
      t.integer :to_pass

      t.belongs_to :game
    end
  end

  def create_game_players
    create_table :game_players do |t|
      t.belongs_to :game
      t.belongs_to :chat
    end
  end

  def self.up
    create_chats
    create_games
    create_levels
    create_codes
    create_bonuses
    create_game_players
  end

  def self.down
    drop_table :chats
    drop_table :levels
    drop_table :games
    drop_table :codes
    drop_table :bonuses
    drop_table :game_players
  end
end
