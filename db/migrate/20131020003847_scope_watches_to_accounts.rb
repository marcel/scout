class ScopeWatchesToAccounts < ActiveRecord::Migration
  def change
    change_table :watches do |t|
      t.integer :account_id
      t.index :account_id
    end
  end
end