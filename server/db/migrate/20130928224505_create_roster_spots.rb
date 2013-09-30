class CreateRosterSpots < ActiveRecord::Migration
  def change
    create_table :roster_spots do |t|
      t.string :yahoo_team_key
      t.string :yahoo_player_key
      t.integer :week
      t.string :position
      t.string :playing_status

      t.timestamps
    end
    add_index :roster_spots, :yahoo_team_key
    add_index :roster_spots, :yahoo_player_key
    add_index :roster_spots, :week
  end
end
