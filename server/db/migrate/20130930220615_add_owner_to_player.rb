class AddOwnerToPlayer < ActiveRecord::Migration
  def change
    change_table :players do |t|
      t.string :owner_key
      t.date :waiver_date
      t.string :ownership_type
      
      t.index :ownership_type
      t.index :waiver_date
      t.index :owner_key
    end
  end
end
