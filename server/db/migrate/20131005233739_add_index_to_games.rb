class AddIndexToGames < ActiveRecord::Migration
  def change
    change_table :games do |t|
      t.index :away_team
      t.index :home_team
    end
    
    change_table :watches do |t|
      t.index :player_id
    end
    
    change_table :expert_ranks do |t|
      t.index :week
      t.index :yahoo_player_key
      t.index :position_type
      t.index [:position_type, :week]
    end
  end
end
