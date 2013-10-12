class CreateExpertRanks < ActiveRecord::Migration
  def change
    create_table :expert_ranks do |t|
      t.string :yahoo_player_key
      t.string :position_type
      t.integer :week
      t.integer :overall_rank
      t.integer :expert_1_rank
      t.integer :expert_2_rank
      t.integer :expert_3_rank
      t.integer :expert_4_rank
      t.integer :expert_5_rank

      t.index [:yahoo_player_key, :week, :position_type], name: :key_week_position_type
      t.timestamps
    end
  end
end
