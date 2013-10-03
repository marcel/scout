class CreateWatches < ActiveRecord::Migration
  def change
    create_table :watches do |t|
      t.integer :player_id
      t.integer :team_id
      
      t.index [:team_id, :player_id]
      
      t.timestamps
    end
  end
end
