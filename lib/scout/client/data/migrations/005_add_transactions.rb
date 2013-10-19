class AddTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.string :yahoo_key
      t.string :type
      t.integer :timestamp
      t.integer :add_roster_change_id
      t.integer :drop_roster_change_id
      t.integer :bid
    end
    
    change_table :transactions do |t|
      t.index :yahoo_key
      t.index :type
      t.index :bid
    end
    
    create_table :roster_changes do |t|    
      t.string :yahoo_player_key
      t.string :type
      t.string :source_type
      t.string :source_team_key
      t.string :destination_type
      t.string :destination_team_key
    end
    
    change_table :roster_changes do |t|
      t.index :yahoo_player_key
      t.index :source_team_key
      t.index :destination_team_key
      t.index :type
    end
    
    change_table :players do |t|
      t.index :yahoo_key
      t.index :fantasy_football_nerd_id
    end
    
    change_table :stats do |t|
      t.index :stat_id
    end
    
    change_table :projections do |t|
      t.index :fantasy_football_nerd_id
      t.index :week
    end
    
    change_table :injuries do |t|
      t.index :fantasy_football_nerd_id
      t.index :week
    end
    
    change_table :teams do |t|
      t.index :yahoo_key
    end
    
    change_table :rosters do |t|
      t.index :yahoo_team_key
      t.index :yahoo_player_key
      t.index [:yahoo_team_key, :week]
      t.index :week
    end
    
    change_table :game_weeks do |t|
      t.index [:week, :start_date]
    end
  end
  
  def self.down
    drop_table :transactions
    drop_table :roster_changes
  end
end