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

ActiveRecord::Schema.define(version: 20131006222019) do

  create_table "accounts", force: true do |t|
    t.string   "username"
    t.text     "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "armchair_analysis_blocks", id: false, force: true do |t|
    t.integer "pid",            null: false
    t.string  "blk",  limit: 7, null: false
    t.string  "brcv", limit: 7, null: false
  end

  add_index "armchair_analysis_blocks", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_completions", id: false, force: true do |t|
    t.integer "pid", null: false
  end

  add_index "armchair_analysis_completions", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_conversions", id: false, force: true do |t|
    t.integer "pid",            null: false
    t.string  "type", limit: 4, null: false
    t.string  "bc",   limit: 7, null: false
    t.string  "psr",  limit: 7, null: false
    t.string  "trg",  limit: 7, null: false
    t.string  "conv", limit: 1, null: false
  end

  add_index "armchair_analysis_conversions", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_cores", id: false, force: true do |t|
    t.integer "gid",            null: false
    t.integer "pid",            null: false
    t.string  "off",  limit: 3, null: false
    t.string  "def",  limit: 3, null: false
    t.string  "type", limit: 4, null: false
    t.integer "dseq", limit: 1, null: false
    t.integer "len",  limit: 1, null: false
    t.boolean "qtr",            null: false
    t.integer "min",  limit: 1, null: false
    t.integer "sec",  limit: 1, null: false
    t.integer "ptso", limit: 1, null: false
    t.integer "ptsd", limit: 1, null: false
    t.integer "timo", limit: 1, null: false
    t.integer "timd", limit: 1, null: false
    t.boolean "dwn",            null: false
    t.integer "ytg",  limit: 1, null: false
    t.integer "yfog", limit: 1, null: false
    t.boolean "zone",           null: false
    t.integer "olid",           null: false
  end

  add_index "armchair_analysis_cores", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_defenses", id: false, force: true do |t|
    t.integer "uid",                                      null: false
    t.integer "gid",                                      null: false
    t.string  "player", limit: 7,                         null: false
    t.decimal "solo",             precision: 3, scale: 1, null: false
    t.decimal "comb",             precision: 3, scale: 1, null: false
    t.decimal "sck",              precision: 2, scale: 1, null: false
    t.integer "saf",                                      null: false
    t.integer "blk",                                      null: false
    t.integer "int",                                      null: false
    t.integer "pdef",                                     null: false
    t.integer "frcv",                                     null: false
    t.integer "forc",                                     null: false
    t.integer "tdd",                                      null: false
    t.integer "peny",                                     null: false
    t.decimal "fpts",             precision: 3, scale: 1, null: false
    t.integer "game",                                     null: false
    t.integer "seas",                                     null: false
    t.integer "year",                                     null: false
    t.string  "team",   limit: 3,                         null: false
  end

  add_index "armchair_analysis_defenses", ["uid"], name: "uid", unique: true, using: :btree

  create_table "armchair_analysis_defensive_backs", id: false, force: true do |t|
    t.integer "pid",           null: false
    t.string  "dfb", limit: 7, null: false
  end

  add_index "armchair_analysis_defensive_backs", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_drives", id: false, force: true do |t|
    t.integer "uid",             null: false
    t.integer "gid",             null: false
    t.integer "fpid",            null: false
    t.string  "tname", limit: 3, null: false
    t.integer "drvn",            null: false
    t.string  "obt",   limit: 4
    t.integer "qtr",             null: false
    t.integer "min",             null: false
    t.integer "sec",             null: false
    t.integer "yfog",            null: false
    t.integer "plays",           null: false
    t.integer "succ",            null: false
    t.integer "rfd",             null: false
    t.integer "pfd",             null: false
    t.integer "ofd",             null: false
    t.integer "ry",              null: false
    t.integer "ra",              null: false
    t.integer "py",              null: false
    t.integer "pa",              null: false
    t.integer "pc",              null: false
    t.integer "peyf",            null: false
    t.integer "peya",            null: false
    t.integer "net",             null: false
    t.string  "res",   limit: 4
  end

  add_index "armchair_analysis_drives", ["uid"], name: "uid", unique: true, using: :btree

  create_table "armchair_analysis_field_goal_extra_points", id: false, force: true do |t|
    t.integer "pid",               null: false
    t.string  "fgxp",    limit: 2, null: false
    t.string  "fkicker", limit: 7, null: false
    t.integer "dist",              null: false
    t.string  "good",    limit: 1, null: false
  end

  add_index "armchair_analysis_field_goal_extra_points", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_first_downs", id: false, force: true do |t|
    t.integer "pid", null: false
  end

  add_index "armchair_analysis_first_downs", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_fumbles", id: false, force: true do |t|
    t.integer "pid",            null: false
    t.string  "fum",  limit: 7, null: false
    t.string  "frcv", limit: 7, null: false
    t.integer "fry",            null: false
    t.string  "forc", limit: 7, null: false
  end

  add_index "armchair_analysis_fumbles", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_games", id: false, force: true do |t|
    t.integer "gid",                                     null: false
    t.integer "seas",                                    null: false
    t.integer "wk",                                      null: false
    t.string  "day",  limit: 3,                          null: false
    t.string  "v",    limit: 3,                          null: false
    t.string  "h",    limit: 3,                          null: false
    t.string  "stad", limit: 45,                         null: false
    t.string  "temp", limit: 4
    t.string  "humd", limit: 4
    t.string  "wspd", limit: 4
    t.string  "wdir", limit: 4
    t.string  "cond", limit: 15
    t.string  "surf", limit: 30,                         null: false
    t.integer "ou",                                      null: false
    t.decimal "sprv",            precision: 3, scale: 1, null: false
    t.integer "ptsv",                                    null: false
    t.integer "ptsh",                                    null: false
  end

  add_index "armchair_analysis_games", ["gid"], name: "gid", unique: true, using: :btree

  create_table "armchair_analysis_interceptions", id: false, force: true do |t|
    t.integer "pid",           null: false
    t.string  "int", limit: 7, null: false
    t.integer "iry",           null: false
  end

  add_index "armchair_analysis_interceptions", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_kickers", id: false, force: true do |t|
    t.integer "uid",                                      null: false
    t.integer "gid",                                      null: false
    t.string  "player", limit: 7,                         null: false
    t.integer "pat",                                      null: false
    t.integer "fgs",                                      null: false
    t.integer "fgm",                                      null: false
    t.integer "fgl",                                      null: false
    t.decimal "fpts",             precision: 3, scale: 1, null: false
  end

  add_index "armchair_analysis_kickers", ["uid"], name: "uid", unique: true, using: :btree

  create_table "armchair_analysis_kickoffs", id: false, force: true do |t|
    t.integer "pid",              null: false
    t.string  "kicker", limit: 7, null: false
    t.integer "kgro",             null: false
    t.integer "knet",             null: false
    t.string  "ktb",    limit: 1, null: false
    t.string  "kr",     limit: 7, null: false
    t.integer "kry",              null: false
  end

  add_index "armchair_analysis_kickoffs", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_knees", id: false, force: true do |t|
    t.integer "pid", null: false
  end

  add_index "armchair_analysis_knees", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_no_huddles", id: false, force: true do |t|
    t.integer "pid", null: false
  end

  add_index "armchair_analysis_no_huddles", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_offenses", id: false, force: true do |t|
    t.integer "uid",                                      null: false
    t.integer "gid",                                      null: false
    t.string  "player", limit: 7,                         null: false
    t.integer "pa",                                       null: false
    t.integer "pc",                                       null: false
    t.integer "py",                                       null: false
    t.integer "int",                                      null: false
    t.integer "tdp",                                      null: false
    t.integer "ra",                                       null: false
    t.integer "sra",                                      null: false
    t.integer "ry",                                       null: false
    t.integer "tdr",                                      null: false
    t.integer "trg",                                      null: false
    t.integer "rec",                                      null: false
    t.integer "recy",                                     null: false
    t.integer "tdre",                                     null: false
    t.integer "fuml",                                     null: false
    t.integer "peny",                                     null: false
    t.decimal "fpts",             precision: 3, scale: 1, null: false
    t.integer "game",                                     null: false
    t.integer "seas",                                     null: false
    t.integer "year",                                     null: false
    t.string  "team",   limit: 3,                         null: false
  end

  add_index "armchair_analysis_offenses", ["uid"], name: "uid", unique: true, using: :btree

  create_table "armchair_analysis_offensive_lines", id: false, force: true do |t|
    t.integer "olid",           null: false
    t.string  "lt",   limit: 7, null: false
    t.string  "lg",   limit: 7, null: false
    t.string  "c",    limit: 7, null: false
    t.string  "rg",   limit: 7, null: false
    t.string  "rt",   limit: 7, null: false
  end

  add_index "armchair_analysis_offensive_lines", ["olid"], name: "olid", unique: true, using: :btree

  create_table "armchair_analysis_passes", id: false, force: true do |t|
    t.integer "pid",           null: false
    t.string  "psr", limit: 7, null: false
    t.string  "trg", limit: 7, null: false
    t.string  "loc", limit: 2, null: false
    t.integer "yds",           null: false
  end

  add_index "armchair_analysis_passes", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_penalties", id: false, force: true do |t|
    t.integer "uid",             null: false
    t.integer "pid",             null: false
    t.string  "ptm",  limit: 3,  null: false
    t.string  "pen",  limit: 7,  null: false
    t.string  "desc", limit: 40, null: false
    t.integer "cat",             null: false
    t.integer "pey",             null: false
    t.string  "act",  limit: 1,  null: false
  end

  add_index "armchair_analysis_penalties", ["uid"], name: "uid", unique: true, using: :btree

  create_table "armchair_analysis_players", id: false, force: true do |t|
    t.string  "player",   limit: 7,                          null: false
    t.string  "fname",    limit: 20,                         null: false
    t.string  "lname",    limit: 25,                         null: false
    t.string  "pname",    limit: 25,                         null: false
    t.string  "pos1",     limit: 2,                          null: false
    t.string  "pos2",     limit: 2
    t.integer "height",                                      null: false
    t.integer "weight",                                      null: false
    t.integer "yob",                                         null: false
    t.decimal "forty",               precision: 3, scale: 2
    t.integer "bench"
    t.decimal "vertical",            precision: 3, scale: 1
    t.integer "broad"
    t.decimal "shuttle",             precision: 3, scale: 2
    t.decimal "cone",                precision: 3, scale: 2
    t.integer "dpos",                                        null: false
    t.string  "col",      limit: 35
    t.string  "dv",       limit: 35
    t.integer "start",                                       null: false
    t.string  "cteam",    limit: 3
  end

  add_index "armchair_analysis_players", ["player"], name: "player", unique: true, using: :btree

  create_table "armchair_analysis_plays", id: false, force: true do |t|
    t.integer "gid",            null: false
    t.integer "pid",            null: false
    t.string  "off",  limit: 3, null: false
    t.string  "def",  limit: 3, null: false
    t.string  "type", limit: 4, null: false
    t.integer "dseq",           null: false
    t.integer "len",            null: false
    t.integer "qtr",            null: false
    t.integer "min",            null: false
    t.integer "sec",            null: false
    t.integer "ptso",           null: false
    t.integer "ptsd",           null: false
    t.integer "timo",           null: false
    t.integer "timd",           null: false
    t.integer "dwn",            null: false
    t.integer "ytg",            null: false
    t.integer "yfog",           null: false
    t.integer "zone",           null: false
    t.integer "olid",           null: false
  end

  add_index "armchair_analysis_plays", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_punts", id: false, force: true do |t|
    t.integer "pid",              null: false
    t.string  "punter", limit: 7, null: false
    t.integer "pgro",             null: false
    t.integer "pnet",             null: false
    t.string  "pts",    limit: 1, null: false
    t.string  "pr",     limit: 7, null: false
    t.integer "pry",              null: false
    t.string  "pfc",    limit: 1, null: false
  end

  add_index "armchair_analysis_punts", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_redzone_opportunities", id: false, force: true do |t|
    t.integer "uid",              null: false
    t.integer "gid",              null: false
    t.string  "player", limit: 7, null: false
    t.integer "pa",               null: false
    t.integer "pc",               null: false
    t.integer "py",               null: false
    t.integer "int",              null: false
    t.integer "ra",               null: false
    t.integer "sra",              null: false
    t.integer "ry",               null: false
    t.integer "trg",              null: false
    t.integer "rec",              null: false
    t.integer "recy",             null: false
    t.integer "fuml",             null: false
    t.integer "peny",             null: false
  end

  add_index "armchair_analysis_redzone_opportunities", ["uid"], name: "uid", unique: true, using: :btree

  create_table "armchair_analysis_rushes", id: false, force: true do |t|
    t.integer "pid",           null: false
    t.string  "bc",  limit: 7, null: false
    t.string  "dir", limit: 2, null: false
    t.integer "yds",           null: false
  end

  add_index "armchair_analysis_rushes", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_sacks", id: false, force: true do |t|
    t.integer "uid",                                     null: false
    t.integer "pid",                                     null: false
    t.string  "qb",    limit: 7,                         null: false
    t.string  "sk",    limit: 7,                         null: false
    t.decimal "value",           precision: 2, scale: 1, null: false
    t.integer "ydsl",                                    null: false
  end

  add_index "armchair_analysis_sacks", ["uid"], name: "uid", unique: true, using: :btree

  create_table "armchair_analysis_safeties", id: false, force: true do |t|
    t.integer "pid",           null: false
    t.string  "saf", limit: 7, null: false
  end

  add_index "armchair_analysis_safeties", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_scoring_plays", id: false, force: true do |t|
    t.integer "pid", null: false
    t.integer "pts", null: false
  end

  add_index "armchair_analysis_scoring_plays", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_shotguns", id: false, force: true do |t|
    t.integer "pid", null: false
  end

  add_index "armchair_analysis_shotguns", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_spikes", id: false, force: true do |t|
    t.integer "pid", null: false
  end

  add_index "armchair_analysis_spikes", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_successful_plays", id: false, force: true do |t|
    t.integer "pid", null: false
  end

  add_index "armchair_analysis_successful_plays", ["pid"], name: "pid", unique: true, using: :btree

  create_table "armchair_analysis_tackles", id: false, force: true do |t|
    t.integer "uid",                                     null: false
    t.integer "pid",                                     null: false
    t.string  "tck",   limit: 7,                         null: false
    t.decimal "value",           precision: 2, scale: 1, null: false
  end

  add_index "armchair_analysis_tackles", ["uid"], name: "uid", unique: true, using: :btree

  create_table "armchair_analysis_teams", id: false, force: true do |t|
    t.integer "tid",                                     null: false
    t.integer "gid",                                     null: false
    t.string  "tname", limit: 3,                         null: false
    t.integer "pts",                                     null: false
    t.integer "1qp",                                     null: false
    t.integer "2qp",                                     null: false
    t.integer "3qp",                                     null: false
    t.integer "4qp",                                     null: false
    t.integer "rfd",                                     null: false
    t.integer "pfd",                                     null: false
    t.integer "ifd",                                     null: false
    t.integer "ry",                                      null: false
    t.integer "ra",                                      null: false
    t.integer "py",                                      null: false
    t.integer "pa",                                      null: false
    t.integer "pc",                                      null: false
    t.integer "sk",                                      null: false
    t.integer "int",                                     null: false
    t.integer "fum",                                     null: false
    t.integer "pu",                                      null: false
    t.integer "gpy",                                     null: false
    t.integer "pr",                                      null: false
    t.integer "pry",                                     null: false
    t.integer "kr",                                      null: false
    t.integer "kry",                                     null: false
    t.integer "ir",                                      null: false
    t.integer "iry",                                     null: false
    t.integer "pen",                                     null: false
    t.decimal "top",             precision: 3, scale: 1, null: false
    t.integer "td",                                      null: false
    t.integer "tdr",                                     null: false
    t.integer "tdp",                                     null: false
    t.integer "tdt",                                     null: false
    t.integer "fgm",                                     null: false
    t.integer "fgat",                                    null: false
    t.integer "fgy",                                     null: false
    t.integer "rza",                                     null: false
    t.integer "rzc",                                     null: false
    t.integer "bry",                                     null: false
    t.integer "bpy",                                     null: false
    t.integer "srp",                                     null: false
    t.integer "s1rp",                                    null: false
    t.integer "s2rp",                                    null: false
    t.integer "s3rp",                                    null: false
    t.integer "spp",                                     null: false
    t.integer "s1pp",                                    null: false
    t.integer "s2pp",                                    null: false
    t.integer "s3pp",                                    null: false
    t.integer "lea",                                     null: false
    t.integer "ley",                                     null: false
    t.integer "lta",                                     null: false
    t.integer "lty",                                     null: false
    t.integer "lga",                                     null: false
    t.integer "lgy",                                     null: false
    t.integer "mda",                                     null: false
    t.integer "mdy",                                     null: false
    t.integer "rga",                                     null: false
    t.integer "rgy",                                     null: false
    t.integer "rta",                                     null: false
    t.integer "rty",                                     null: false
    t.integer "rea",                                     null: false
    t.integer "rey",                                     null: false
    t.integer "r1a",                                     null: false
    t.integer "r1y",                                     null: false
    t.integer "r2a",                                     null: false
    t.integer "r2y",                                     null: false
    t.integer "r3a",                                     null: false
    t.integer "r3y",                                     null: false
    t.integer "qba",                                     null: false
    t.integer "qby",                                     null: false
    t.integer "sla",                                     null: false
    t.integer "sly",                                     null: false
    t.integer "sma",                                     null: false
    t.integer "smy",                                     null: false
    t.integer "sra",                                     null: false
    t.integer "sry",                                     null: false
    t.integer "dla",                                     null: false
    t.integer "dly",                                     null: false
    t.integer "dma",                                     null: false
    t.integer "dmy",                                     null: false
    t.integer "dra",                                     null: false
    t.integer "dry",                                     null: false
    t.integer "wr1a",                                    null: false
    t.integer "wr1y",                                    null: false
    t.integer "wr3a",                                    null: false
    t.integer "wr3y",                                    null: false
    t.integer "tea",                                     null: false
    t.integer "tey",                                     null: false
    t.integer "rba",                                     null: false
    t.integer "rby",                                     null: false
    t.integer "sga",                                     null: false
    t.integer "sgy",                                     null: false
    t.integer "p1a",                                     null: false
    t.integer "p1y",                                     null: false
    t.integer "p2a",                                     null: false
    t.integer "p2y",                                     null: false
    t.integer "p3a",                                     null: false
    t.integer "p3y",                                     null: false
    t.integer "spc",                                     null: false
    t.integer "mpc",                                     null: false
    t.integer "lpc",                                     null: false
    t.integer "q1ra",                                    null: false
    t.integer "q1ry",                                    null: false
    t.integer "q1pa",                                    null: false
    t.integer "q1py",                                    null: false
    t.integer "lcra",                                    null: false
    t.integer "lcry",                                    null: false
    t.integer "lcpa",                                    null: false
    t.integer "lcpy",                                    null: false
    t.integer "rzra",                                    null: false
    t.integer "rzry",                                    null: false
    t.integer "rzpa",                                    null: false
    t.integer "rzpy",                                    null: false
    t.integer "sky",                                     null: false
    t.decimal "lbs",             precision: 3, scale: 1, null: false
    t.decimal "dbs",             precision: 3, scale: 1, null: false
    t.integer "sfpy",                                    null: false
    t.integer "drv",                                     null: false
    t.integer "npy",                                     null: false
    t.integer "tb",                                      null: false
    t.integer "i20",                                     null: false
    t.integer "rtd",                                     null: false
    t.decimal "lnr",             precision: 3, scale: 1, null: false
    t.decimal "lnp",             precision: 3, scale: 1, null: false
    t.decimal "lbr",             precision: 3, scale: 1, null: false
    t.decimal "lbp",             precision: 3, scale: 1, null: false
    t.decimal "dbr",             precision: 3, scale: 1, null: false
    t.decimal "dbp",             precision: 3, scale: 1, null: false
    t.integer "nha",                                     null: false
    t.integer "s3a",                                     null: false
    t.integer "s3c",                                     null: false
    t.integer "l3a",                                     null: false
    t.integer "l3c",                                     null: false
    t.integer "stf",                                     null: false
    t.integer "dp",                                      null: false
    t.integer "fsp",                                     null: false
    t.integer "ohp",                                     null: false
    t.integer "pbep",                                    null: false
    t.integer "dlp",                                     null: false
    t.integer "dsp",                                     null: false
    t.integer "dum",                                     null: false
    t.integer "pfn",                                     null: false
  end

  add_index "armchair_analysis_teams", ["gid", "tname"], name: "index_armchair_analysis_teams_on_gid_and_tname", using: :btree
  add_index "armchair_analysis_teams", ["tid"], name: "tid", unique: true, using: :btree
  add_index "armchair_analysis_teams", ["tname"], name: "index_armchair_analysis_teams_on_tname", using: :btree

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

  add_index "expert_ranks", ["position_type", "week"], name: "index_expert_ranks_on_position_type_and_week", using: :btree
  add_index "expert_ranks", ["position_type"], name: "index_expert_ranks_on_position_type", using: :btree
  add_index "expert_ranks", ["week"], name: "index_expert_ranks_on_week", using: :btree
  add_index "expert_ranks", ["yahoo_player_key", "week", "position_type"], name: "key_week_position_type", using: :btree
  add_index "expert_ranks", ["yahoo_player_key"], name: "index_expert_ranks_on_yahoo_player_key", using: :btree

  create_table "game_weeks", force: true do |t|
    t.integer "week"
    t.date    "start_date"
    t.date    "end_date"
  end

  add_index "game_weeks", ["week", "start_date"], name: "index_game_weeks_on_week_and_start_date", using: :btree

  create_table "games", force: true do |t|
    t.integer  "week"
    t.integer  "season"
    t.string   "away_team"
    t.string   "home_team"
    t.time     "kickoff_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "games", ["away_team"], name: "index_games_on_away_team", using: :btree
  add_index "games", ["home_team"], name: "index_games_on_home_team", using: :btree

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

  add_index "injuries", ["fantasy_football_nerd_id"], name: "index_injuries_on_fantasy_football_nerd_id", using: :btree
  add_index "injuries", ["week", "game_status"], name: "index_injuries_on_week_and_game_status", using: :btree
  add_index "injuries", ["week", "injury"], name: "index_injuries_on_week_and_injury", using: :btree
  add_index "injuries", ["week", "practice_status"], name: "index_injuries_on_week_and_practice_status", using: :btree
  add_index "injuries", ["week"], name: "index_injuries_on_week", using: :btree

  create_table "player_point_totals", force: true do |t|
    t.string   "yahoo_player_key"
    t.integer  "season"
    t.float    "total"
    t.integer  "week"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "player_point_totals", ["season", "week"], name: "index_player_point_totals_on_season_and_week", using: :btree
  add_index "player_point_totals", ["season"], name: "index_player_point_totals_on_season", using: :btree
  add_index "player_point_totals", ["total"], name: "index_player_point_totals_on_total", using: :btree
  add_index "player_point_totals", ["week"], name: "index_player_point_totals_on_week", using: :btree
  add_index "player_point_totals", ["yahoo_player_key"], name: "index_player_point_totals_on_yahoo_player_key", using: :btree

  create_table "player_stat_values", force: true do |t|
    t.string   "yahoo_player_key"
    t.integer  "season"
    t.integer  "week"
    t.integer  "yahoo_stat_id"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "player_stat_values", ["week"], name: "index_player_stat_values_on_week", using: :btree
  add_index "player_stat_values", ["yahoo_player_key"], name: "index_player_stat_values_on_yahoo_player_key", using: :btree
  add_index "player_stat_values", ["yahoo_stat_id"], name: "index_player_stat_values_on_yahoo_stat_id", using: :btree

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
    t.string   "armchair_analysis_id"
    t.string   "armchair_analysis_team_name"
  end

  add_index "players", ["armchair_analysis_id"], name: "index_players_on_armchair_analysis_id", using: :btree
  add_index "players", ["armchair_analysis_team_name"], name: "index_players_on_armchair_analysis_team_name", using: :btree
  add_index "players", ["fantasy_football_nerd_id"], name: "index_players_on_fantasy_football_nerd_id", using: :btree
  add_index "players", ["owner_key"], name: "index_players_on_owner_key", using: :btree
  add_index "players", ["ownership_type"], name: "index_players_on_ownership_type", using: :btree
  add_index "players", ["position"], name: "index_players_on_position", using: :btree
  add_index "players", ["waiver_date"], name: "index_players_on_waiver_date", using: :btree
  add_index "players", ["yahoo_key"], name: "index_players_on_yahoo_key", using: :btree

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

  add_index "projections", ["fantasy_football_nerd_id"], name: "index_projections_on_fantasy_football_nerd_id", using: :btree
  add_index "projections", ["week", "standard"], name: "index_projections_on_week_and_standard", using: :btree
  add_index "projections", ["week"], name: "index_projections_on_week", using: :btree

  create_table "roster_adds", force: true do |t|
    t.string  "yahoo_team_key"
    t.integer "week"
    t.integer "value"
  end

  create_table "roster_changes", force: true do |t|
    t.string   "yahoo_player_key"
    t.string   "type"
    t.string   "source_type"
    t.string   "source_team_key"
    t.string   "destination_type"
    t.string   "destination_team_key"
    t.integer  "week"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roster_changes", ["destination_team_key"], name: "index_roster_changes_on_destination_team_key", using: :btree
  add_index "roster_changes", ["source_team_key"], name: "index_roster_changes_on_source_team_key", using: :btree
  add_index "roster_changes", ["yahoo_player_key"], name: "index_roster_changes_on_yahoo_player_key", using: :btree

  create_table "roster_spots", force: true do |t|
    t.string   "yahoo_team_key"
    t.string   "yahoo_player_key"
    t.integer  "week"
    t.string   "position"
    t.string   "playing_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",           default: true
  end

  add_index "roster_spots", ["week"], name: "index_roster_spots_on_week", using: :btree
  add_index "roster_spots", ["yahoo_player_key"], name: "index_roster_spots_on_yahoo_player_key", using: :btree
  add_index "roster_spots", ["yahoo_team_key", "week"], name: "index_roster_spots_on_yahoo_team_key_and_week", using: :btree
  add_index "roster_spots", ["yahoo_team_key"], name: "index_roster_spots_on_yahoo_team_key", using: :btree

  create_table "stats", force: true do |t|
    t.string  "name"
    t.integer "yahoo_stat_id"
    t.integer "sort_order"
    t.string  "position_type"
    t.string  "display_name"
  end

  add_index "stats", ["yahoo_stat_id"], name: "index_stats_on_yahoo_stat_id", using: :btree

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

  add_index "teams", ["yahoo_key"], name: "index_teams_on_yahoo_key", using: :btree

  create_table "transactions", force: true do |t|
    t.string   "yahoo_key"
    t.string   "type"
    t.integer  "timestamp"
    t.integer  "add_roster_change_id"
    t.integer  "drop_roster_change_id"
    t.integer  "bid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactions", ["type"], name: "index_transactions_on_type", using: :btree
  add_index "transactions", ["yahoo_key"], name: "index_transactions_on_yahoo_key", using: :btree

  create_table "watches", force: true do |t|
    t.integer  "player_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "votes",      default: 1
  end

  add_index "watches", ["player_id"], name: "index_watches_on_player_id", using: :btree
  add_index "watches", ["team_id", "player_id"], name: "index_watches_on_team_id_and_player_id", using: :btree

end
