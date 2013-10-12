class ArmchairAnalysis::RedzoneOpportunity < ActiveRecord::Base
  belongs_to :player, {
    foreign_key: :armchair_analysis_id,
    primary_key: :player,
    class_name: "::Player"
  }
  
  belongs_to :game, {
    foreign_key: :gid,
    primary_key: :gid,
    class_name: "ArmchairAnalysis::Game"
  }
end
