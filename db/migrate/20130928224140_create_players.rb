class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :yahoo_key
      t.integer :fantasy_football_nerd_id
      t.string :full_name
      t.string :first_name
      t.string :last_name
      t.text :xml

      t.timestamps
    end
    add_index :players, :yahoo_key
    add_index :players, :fantasy_football_nerd_id
    add_index :players, :full_name
  end
end
