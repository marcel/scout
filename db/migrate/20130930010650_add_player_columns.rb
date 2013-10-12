class AddPlayerColumns < ActiveRecord::Migration
  def change
    change_table :players do |t|
      t.remove :xml
      t.string :playing_status
      t.string :team_full_name
      t.string :team_abbr
      t.integer :bye_week
      t.integer :uniform_number
      t.string :position
      t.string :position_type
    end
  end
end
