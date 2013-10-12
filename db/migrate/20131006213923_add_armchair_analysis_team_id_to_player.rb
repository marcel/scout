class AddArmchairAnalysisTeamIdToPlayer < ActiveRecord::Migration
  def change
    change_table :players do |t|
      t.string :armchair_analysis_team_name
      t.index :armchair_analysis_team_name
    end
  end
end
