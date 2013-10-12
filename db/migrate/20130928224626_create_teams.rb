class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :yahoo_key
      t.string :name
      t.integer :number_of_moves
      t.integer :number_of_trades

      t.timestamps
    end
    add_index :teams, :yahoo_key
  end
end
