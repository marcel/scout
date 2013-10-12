class RenameOldRosterToRosterSpot < ActiveRecord::Migration
  def change
    rename_table :rosters, :roster_spots
  end
end
