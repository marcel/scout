class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :week
      t.integer :season
      t.string :away_team
      t.string :home_team
      t.time :kickoff_time

      t.timestamps
    end
  end
end
