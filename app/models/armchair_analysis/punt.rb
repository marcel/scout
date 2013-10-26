class ArmchairAnalysis::Punt < ActiveRecord::Base
  belongs_to :play, {
    primary_key: :pid,
    foreign_key: :pid
  }

  has_one :game, through: :play


  has_one :returner, {
    primary_key: :pr,
    foreign_key: :armchair_analysis_id,
    class_name: '::Player'
  }
end
