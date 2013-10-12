class AddIndexOnArmchairAnalysisTeamTableIds < ActiveRecord::Migration
  def change
    change_table :armchair_analysis_teams do |t|
      t.index [:gid, :tname]
      t.index :tname
    end
    
    change_table :players do |t|
      t.index :position
    end
  end
end
