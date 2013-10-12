class AddArmchairAnalysisIdToPlayer < ActiveRecord::Migration
  def change
    change_table :players do |t|
      t.string :armchair_analysis_id
      t.index :armchair_analysis_id
    end
  end
end
