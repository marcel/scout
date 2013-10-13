class VariousIndexes < ActiveRecord::Migration
  def change
    change_table :armchair_analysis_offenses do |t|
      t.index :gid
    end
  end
end
