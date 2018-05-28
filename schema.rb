# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2) do

  create_table "bonuses", force: :cascade do |t|
    t.datetime "time"
    t.integer "code_id"
    t.integer "chat_id"
    t.index ["chat_id"], name: "index_bonuses_on_chat_id"
    t.index ["code_id"], name: "index_bonuses_on_code_id"
  end

  create_table "chats", force: :cascade do |t|
    t.string "chat_id"
    t.string "name"
  end

  create_table "codes", force: :cascade do |t|
    t.string "value_hash"
    t.integer "bonus"
    t.integer "level_id"
    t.index ["level_id"], name: "index_codes_on_level_id"
  end

  create_table "game_players", force: :cascade do |t|
    t.integer "game_id"
    t.integer "chat_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "allow_teams"
    t.datetime "start"
    t.integer "chat_id"
    t.string "status"
  end

  create_table "levels", force: :cascade do |t|
    t.string "name"
    t.string "task"
    t.integer "duration"
    t.integer "to_pass"
    t.integer "game_id"
  end

end
