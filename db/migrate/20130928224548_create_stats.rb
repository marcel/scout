class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.string :name
      t.integer :stat_id
      t.integer :sort_order
      t.string :position_type
      t.string :display_name

      t.timestamps
    end
    add_index :stats, :stat_id
  end
end
