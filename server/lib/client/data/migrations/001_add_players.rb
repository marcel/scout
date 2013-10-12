class AddPlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.string :yahoo_key
      t.integer :fantasy_football_nerd_id
      t.string :full_name
      t.string :first_name
      t.string :last_name
      t.text :xml
      
      t.timestamps
    end
  end

  def self.down
    drop_table :players
  end
end