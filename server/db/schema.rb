# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20131003083712) do

  create_table "accounts", force: true do |t|
    t.string   "username"
    t.text     "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expert_ranks", force: true do |t|
    t.string   "yahoo_player_key"
    t.string   "position_type"
    t.integer  "week"
    t.integer  "overall_rank"
    t.integer  "expert_1_rank"
    t.integer  "expert_2_rank"
    t.integer  "expert_3_rank"
    t.integer  "expert_4_rank"
    t.integer  "expert_5_rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "expert_ranks", ["yahoo_player_key", "week", "position_type"], name: "key_week_position_type"

  create_table "game_weeks", force: true do |t|
    t.integer "week"
    t.date    "start_date"
    t.date    "end_date"
  end

  add_index "game_weeks", ["week", "start_date"], name: "index_game_weeks_on_week_and_start_date"

  create_table "injuries", force: true do |t|
    t.integer  "fantasy_football_nerd_id"
    t.integer  "week"
    t.string   "injury"
    t.string   "practice_status"
    t.string   "game_status"
    t.date     "last_update"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "injuries", ["fantasy_football_nerd_id"], name: "index_injuries_on_fantasy_football_nerd_id"
  add_index "injuries", ["week", "game_status"], name: "index_injuries_on_week_and_game_status"
  add_index "injuries", ["week", "injury"], name: "index_injuries_on_week_and_injury"
  add_index "injuries", ["week", "practice_status"], name: "index_injuries_on_week_and_practice_status"
  add_index "injuries", ["week"], name: "index_injuries_on_week"

  create_table "player_point_totals", force: true do |t|
    t.string   "yahoo_player_key"
    t.integer  "season"
    t.float    "total"
    t.integer  "week"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "player_point_totals", ["season", "week"], name: "index_player_point_totals_on_season_and_week"
  add_index "player_point_totals", ["season"], name: "index_player_point_totals_on_season"
  add_index "player_point_totals", ["total"], name: "index_player_point_totals_on_total"
  add_index "player_point_totals", ["week"], name: "index_player_point_totals_on_week"
  add_index "player_point_totals", ["yahoo_player_key"], name: "index_player_point_totals_on_yahoo_player_key"

  create_table "players", force: true do |t|
    t.string   "yahoo_key"
    t.integer  "fantasy_football_nerd_id"
    t.string   "full_name"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "playing_status"
    t.string   "team_full_name"
    t.string   "team_abbr"
    t.integer  "bye_week"
    t.integer  "uniform_number"
    t.string   "position"
    t.string   "position_type"
    t.string   "headshot"
    t.string   "owner_key"
    t.date     "waiver_date"
    t.string   "ownership_type"
  end

  add_index "players", ["fantasy_football_nerd_id"], name: "index_players_on_fantasy_football_nerd_id"
  add_index "players", ["owner_key"], name: "index_players_on_owner_key"
  add_index "players", ["ownership_type"], name: "index_players_on_ownership_type"
  add_index "players", ["waiver_date"], name: "index_players_on_waiver_date"
  add_index "players", ["yahoo_key"], name: "index_players_on_yahoo_key"

  create_table "projections", force: true do |t|
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

  add_index "projections", ["fantasy_football_nerd_id"], name: "index_projections_on_fantasy_football_nerd_id"
  add_index "projections", ["week", "standard"], name: "index_projections_on_week_and_standard"
  add_index "projections", ["week"], name: "index_projections_on_week"

  create_table "roster_adds", force: true do |t|
    t.string  "yahoo_team_key"
    t.integer "week"
    t.integer "value"
  end

  create_table "roster_changes", force: true do |t|
    t.string "yahoo_player_key"
    t.string "type"
    t.string "source_type"
    t.string "source_team_key"
    t.string "destination_type"
    t.string "destination_team_key"
  end

  add_index "roster_changes", ["destination_team_key"], name: "index_roster_changes_on_destination_team_key"
  add_index "roster_changes", ["source_team_key"], name: "index_roster_changes_on_source_team_key"
  add_index "roster_changes", ["yahoo_player_key"], name: "index_roster_changes_on_yahoo_player_key"

  create_table "roster_spots", force: true do |t|
    t.string   "yahoo_team_key"
    t.string   "yahoo_player_key"
    t.integer  "week"
    t.string   "position"
    t.string   "playing_status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roster_spots", ["week"], name: "index_roster_spots_on_week"
  add_index "roster_spots", ["yahoo_player_key"], name: "index_roster_spots_on_yahoo_player_key"
  add_index "roster_spots", ["yahoo_team_key", "week"], name: "index_roster_spots_on_yahoo_team_key_and_week"
  add_index "roster_spots", ["yahoo_team_key"], name: "index_roster_spots_on_yahoo_team_key"

  create_table "stats", force: true do |t|
    t.string  "name"
    t.integer "stat_id"
    t.integer "sort_order"
    t.string  "position_type"
    t.string  "display_name"
  end

  add_index "stats", ["stat_id"], name: "index_stats_on_stat_id"

  create_table "teams", force: true do |t|
    t.string   "yahoo_key"
    t.string   "name"
    t.integer  "moves"
    t.integer  "trades"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
    t.integer  "division_id"
    t.integer  "waiver_priority"
    t.integer  "faab_balance"
    t.string   "manager"
  end

  add_index "teams", ["yahoo_key"], name: "index_teams_on_yahoo_key"

  create_table "transactions", force: true do |t|
    t.string  "yahoo_key"
    t.string  "type"
    t.integer "timestamp"
    t.integer "add_roster_change_id"
    t.integer "drop_roster_change_id"
    t.integer "bid"
  end

  add_index "transactions", ["type"], name: "index_transactions_on_type"
  add_index "transactions", ["yahoo_key"], name: "index_transactions_on_yahoo_key"

  create_table "watches", force: true do |t|
    t.integer  "player_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "votes",      default: 1
  end

  add_index "watches", ["team_id", "player_id"], name: "index_watches_on_team_id_and_player_id"

end
