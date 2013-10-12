class CreatePlayerStatValues < ActiveRecord::Migration
  def change
    create_table :player_stat_values do |t|
      t.string :yahoo_player_key
      t.integer :season
      t.integer :week
      t.integer :stat_id
      t.float :value

      t.timestamps
    end
    add_index :player_stat_values, :yahoo_player_key
    add_index :player_stat_values, :week
    add_index :player_stat_values, :stat_id
  end
end
