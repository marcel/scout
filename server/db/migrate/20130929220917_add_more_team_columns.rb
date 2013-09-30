class AddMoreTeamColumns < ActiveRecord::Migration
  def change
    change_table :teams do |t|
      t.string :logo
      t.integer :division_id
      t.integer :waiver_priority
      t.integer :faab_balance 
      t.string :manager
      t.rename :number_of_moves, :moves
      t.rename :number_of_trades, :trades
    end
  end
end
