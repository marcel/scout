class RenameStatIdToBeLessAmbiguous < ActiveRecord::Migration
  def change
    change_table :player_stat_values do |t|
      t.rename :stat_id, :yahoo_stat_id
    end
    
    change_table :stats do |t|
      t.rename :stat_id, :yahoo_stat_id
    end
  end
end
