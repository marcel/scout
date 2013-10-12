class AddTimestampsToRosterChanges < ActiveRecord::Migration
  def change
    change_table :roster_changes do |t|
      t.integer :week
      t.timestamps
    end
    
    change_table :roster_spots do |t|
      t.boolean :active, default: true
    end
    
    change_table :transactions do |t|
      t.timestamps
    end
  end
end
