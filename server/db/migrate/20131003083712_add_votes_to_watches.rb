class AddVotesToWatches < ActiveRecord::Migration
  def change
    change_table :watches do |t|
      t.integer :votes, :default => 1
    end
  end
end
