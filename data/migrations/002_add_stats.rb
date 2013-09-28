class AddStats < ActiveRecord::Migration
  def self.up
    create_table :stats do |t|
      t.string :name
      t.integer :stat_id
      t.integer :sort_order
      t.string :position_type
      t.string :display_name      
    end
  end

  def self.down
    drop_table :stats
  end
end