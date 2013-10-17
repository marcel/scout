class ArmchairAnalysis::Player < ActiveRecord::Base
  belongs_to :main_player, {
    foreign_key: :player,
    primary_key: :armchair_analysis_id,
    class_name: "::Player"
  }
end
