class CreateGameWeeks < ActiveRecord::Migration
  def change
    create_table :game_weeks do |t|
      t.integer :week
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
    add_index :game_weeks, :week
  end
end
