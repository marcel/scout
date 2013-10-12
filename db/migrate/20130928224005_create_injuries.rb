class CreateInjuries < ActiveRecord::Migration
  def change
    create_table :injuries do |t|
      t.integer :fantasy_football_nerd_id
      t.integer :week
      t.string :injury
      t.string :practice_status
      t.string :game_status
      t.date :last_update

      t.timestamps
    end
    add_index :injuries, :fantasy_football_nerd_id
    add_index :injuries, :week
  end
end
