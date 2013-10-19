class CreateGameForecasts < ActiveRecord::Migration
  def change
    create_table :game_forecasts do |t|
      t.integer :game_id
      t.string :coded
      t.string :icon
      t.string :description
      t.integer :min_temp
      t.integer :max_temp
      t.integer :temp_feels_like
      t.integer :humidity
      t.integer :pop
      t.integer :wind_speed
      t.text :json

      t.timestamps

      t.index :game_id
    end
  end
end
