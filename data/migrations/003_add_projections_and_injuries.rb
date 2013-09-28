class AddProjectionsAndInjuries < ActiveRecord::Migration
  def self.up
    create_table :projections do |t|
      t.integer :fantasy_football_nerd_id
      t.integer :week
      t.float :standard_high
      t.float :standard_low
      t.float :standard
      t.float :ppr_high
      t.float :ppr_low
      t.float :ppr
      t.integer :rank

      t.timestamps
    end

    create_table :injuries do |t|
      t.integer :fantasy_football_nerd_id
      t.integer :week
      t.string :injury
      t.string :practice_status
      t.string :game_status
      t.date :last_update

      t.timestamps
    end
  end

  def self.down
    drop_table :projections
    drop_table :injuries
  end
end