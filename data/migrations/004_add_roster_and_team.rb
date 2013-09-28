class AddRosterAndTeam < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.string :yahoo_key
      t.string :name
      t.integer :number_of_moves
      t.integer :number_of_trades
      
      t.timestamps      
    end
    
    create_table :rosters do |t|
      t.string :yahoo_team_key
      t.string :yahoo_player_key
      t.integer :week
      t.string :position
      t.string :playing_status
      
      t.timestamps
    end
    
    create_table :game_weeks do |t|
      t.integer :week
      t.date :start_date
      t.date :end_date
    end
    
    create_table :roster_adds do |t|
      t.string :yahoo_team_key
      t.integer :week
      t.integer :value
    end
  end

  def self.down
    drop_table :teams
    drop_table :rosters
  end
end