class CreateProjections < ActiveRecord::Migration
  def change
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
    add_index :projections, :fantasy_football_nerd_id
    add_index :projections, :week
  end
end
