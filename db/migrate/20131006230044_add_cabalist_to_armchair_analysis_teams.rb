class AddCabalistToArmchairAnalysisTeams < ActiveRecord::Migration

  def up
    add_column :armchair_analysis_teams, :autoclassified_at, :timestamp
  end

  def down
    remove_column :armchair_analysis_teams, :autoclassified_at
  end
  
end
