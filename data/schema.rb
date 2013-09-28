# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 5) do

  create_table "game_weeks", :force => true do |t|
    t.integer "week"
    t.date    "start_date"
    t.date    "end_date"
  end

  add_index "game_weeks", ["week", "start_date"], :name => "index_game_weeks_on_week_and_start_date"

  create_table "injuries", :force => true do |t|
    t.integer  "fantasy_football_nerd_id"
    t.integer  "week"
    t.string   "injury"
    t.string   "practice_status"
    t.string   "game_status"
    t.date     "last_update"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "injuries", ["fantasy_football_nerd_id"], :name => "index_injuries_on_fantasy_football_nerd_id"
  add_index "injuries", ["week"], :name => "index_injuries_on_week"

  create_table "players", :force => true do |t|
    t.string   "yahoo_key"
    t.integer  "fantasy_football_nerd_id"
    t.string   "full_name"
    t.string   "first_name"
    t.string   "last_name"
    t.text     "xml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "players", ["fantasy_football_nerd_id"], :name => "index_players_on_fantasy_football_nerd_id"
  add_index "players", ["yahoo_key"], :name => "index_players_on_yahoo_key"

  create_table "projections", :force => true do |t|
    t.integer  "fantasy_football_nerd_id"
    t.integer  "week"
    t.float    "standard_high"
    t.float    "standard_low"
    t.float    "standard"
    t.float    "ppr_high"
    t.float    "ppr_low"
    t.float    "ppr"
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projections", ["fantasy_football_nerd_id"], :name => "index_projections_on_fantasy_football_nerd_id"
  add_index "projections", ["week"], :name => "index_projections_on_week"

  create_table "roster_adds", :force => true do |t|
    t.string  "yahoo_team_key"
    t.integer "week"
    t.integer "value"
  end

  create_table "roster_changes", :force => true do |t|
    t.string "yahoo_player_key"
    t.string "type"
    t.string "source_type"
    t.string "source_team_key"
    t.string "destination_type"
    t.string "destination_team_key"
  end

  add_index "roster_changes", ["destination_team_key"], :name => "index_roster_changes_on_destination_team_key"
  add_index "roster_changes", ["source_team_key"], :name => "index_roster_changes_on_source_team_key"
  add_index "roster_changes", ["yahoo_player_key"], :name => "index_roster_changes_on_yahoo_player_key"

  create_table "rosters", :force => true do |t|
    t.string   "yahoo_team_key"
    t.string   "yahoo_player_key"
    t.integer  "week"
    t.string   "position"
    t.string   "playing_status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rosters", ["week"], :name => "index_rosters_on_week"
  add_index "rosters", ["yahoo_player_key"], :name => "index_rosters_on_yahoo_player_key"
  add_index "rosters", ["yahoo_team_key", "week"], :name => "index_rosters_on_yahoo_team_key_and_week"
  add_index "rosters", ["yahoo_team_key"], :name => "index_rosters_on_yahoo_team_key"

  create_table "stats", :force => true do |t|
    t.string  "name"
    t.integer "stat_id"
    t.integer "sort_order"
    t.string  "position_type"
    t.string  "display_name"
  end

  add_index "stats", ["stat_id"], :name => "index_stats_on_stat_id"

  create_table "teams", :force => true do |t|
    t.string   "yahoo_key"
    t.string   "name"
    t.integer  "number_of_moves"
    t.integer  "number_of_trades"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teams", ["yahoo_key"], :name => "index_teams_on_yahoo_key"

  create_table "transactions", :force => true do |t|
    t.string  "yahoo_key"
    t.string  "type"
    t.integer "timestamp"
    t.integer "add_roster_change_id"
    t.integer "drop_roster_change_id"
    t.integer "bid"
  end

  add_index "transactions", ["type"], :name => "index_transactions_on_type"
  add_index "transactions", ["yahoo_key"], :name => "index_transactions_on_yahoo_key"

end
