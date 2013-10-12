class CreatePlayerPoints < ActiveRecord::Migration
  def change
    create_table :player_point_totals do |t|
      t.string :yahoo_player_key
      t.integer :season
      t.float :total
      t.integer :week

      t.timestamps
    end

    change_table :player_point_totals do |t|
      t.index [:season, :week]
      t.index :yahoo_player_key
      t.index :season
      t.index :total
      t.index :week
    end

    change_table :projections do |t|
      t.index [:week, :standard]
    end

    change_table :injuries do |t|
      t.index [:week, :game_status]
      t.index [:week, :injury]
      t.index [:week, :practice_status]
    end
  end
end