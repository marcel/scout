class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :yahoo_key
      t.string :type
      t.integer :timestamp
      t.integer :add_roster_change_id
      t.integer :drop_roster_change_id
      t.integer :bid

      t.timestamps
    end
    add_index :transactions, :yahoo_key
    add_index :transactions, :type
    add_index :transactions, :add_roster_change_id
    add_index :transactions, :drop_roster_change_id
  end
end
