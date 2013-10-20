#!/usr/bin/env ruby
require 'optparse'

TABLE_PREFIX = 'armchair_analysis'
DEFAULT_DB = 'scout_development'
TABLE_TRANSLATIONS = Hash.new do |h, k|
  h[k] = k
end

TABLE_TRANSLATIONS.update(
  blocks: :blocks, # same
  comps: :completions,
  convs: :conversions,
  core: :plays,  # same
  dbacks: :defensive_backs,
  defense: :defenses,
  drives: :drives,
  fdowns: :first_downs,
  fgxp: :field_goal_extra_points,
  fumbles: :fumbles, # same
  games: :games, # same
  ints: :interceptions,
  kickers: :kickers, # same
  kickoffs: :kickoffs, # same
  knees: :knees, # same
  nohuddle: :no_huddles,
  offense: :offenses,
  oline: :offensive_lines,
  pass: :passes,
  penalties: :penalties, # same
  players: :players, # same
  punts: :punts, # same
  redzone: :redzone_opportunities,
  rush: :rushes,
  sacks: :sacks, # same
  safeties: :safeties, # same
  scoring: :scoring_plays,
  shotgun: :shotguns,
  spikes: :spikes, # same
  splays: :successful_plays,
  tackles: :tackles, # same
  team: :teams
)

if __FILE__ == $0
  def normalize_csv_file(file)
    temp_file_name = "#{file}_normalized.csv"
    system("tr -d '\r' < #{file}  > #{temp_file_name}")
    system("mv #{temp_file_name} #{file}")
  end

  case command = ARGV.shift
  when 'translate-schema'
    drop_tables = ARGV.any? {|arg| arg == '--replace-tables' }

    IO.readlines(ARGV.first).each do |line|
      current_table = nil
      next if line[/^--/]

      line.gsub!('tinyint', 'int')

      line.gsub!(/^(CREATE TABLE IF NOT EXISTS) `(\w+)` \(/) do
        translated_table_name = TABLE_TRANSLATIONS[$2.to_sym]
        table_name = "#{TABLE_PREFIX}_#{translated_table_name}"
        prefix = drop_tables ? "DROP TABLE IF EXISTS #{table_name};\n" : ''

        prefix + "#{$1} `#{table_name}` ("
      end

      line.gsub!(/^(\s+)`([A-Z0-9]+)` /) do |match|
        "#{$1}`#{$2.downcase}` "
      end

      line.gsub!(/UNIQUE\s+KEY\s+`([A-Z0-9]+)`\s+\(`([A-Z0-9]+)`\)/) do |match|
        "UNIQUE KEY `#{$1.downcase}` (`#{$2.downcase}`)"
      end

      puts line
    end
  when 'import'
    db = ARGV.first || DEFAULT_DB

    auth = case db
    when 'scout_production'
      "-u scout -psecret"
    else
      ''
    end

    STDERR.puts "Attempting import into #{db}"

    import_sql_format = %Q{mysql #{db} #{auth} --local-infile=1 -e 'LOAD DATA LOCAL INFILE "%s" REPLACE INTO TABLE %s FIELDS TERMINATED BY "," OPTIONALLY ENCLOSED BY """" IGNORE 1 LINES'}

    TABLE_TRANSLATIONS.keys.each do |key|
      table_name = [TABLE_PREFIX, TABLE_TRANSLATIONS[key].to_s].join('_')
      csv_file   = key.to_s.upcase + '.csv'
      if File.exists?(csv_file)
        normalize_csv_file(csv_file)

        STDERR.puts "Importing `#{key}` -> `#{table_name}`"
        import_sql = import_sql_format % [csv_file, table_name]
        system(import_sql)
      else
        STDERR.puts "[WARNING] File `#{csv_file}` does not exist"
      end
    end
  else
    abort("Unrecognized command `#{command}`")
  end
end