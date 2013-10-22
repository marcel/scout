class AddPrecipitationInchesToGameForecast < ActiveRecord::Migration
  def change
    change_table :game_forecasts do |t|
      t.float :inches_of_precipitation
      t.float :inches_of_snow
    end

    GameForecast.all.each do |gf|
      extra_attributes = JSON.parse(gf.json)
      gf.inches_of_precipitation = extra_attributes['precipIN']
      gf.inches_of_snow = extra_attributes['snowIN']
      gf.save
    end
  end
end
