class CreateRosterChanges < ActiveRecord::Migration
  def change
    create_table :roster_changes do |t|
      t.string :yahoo_player_key
      t.string :type
      t.string :source_type
      t.string :source_team_key
      t.string :destination_type
      t.string :destination_team_key

      t.timestamps
    end
    add_index :roster_changes, :yahoo_player_key
    add_index :roster_changes, :source_team_key
    add_index :roster_changes, :destination_team_key
  end
end
