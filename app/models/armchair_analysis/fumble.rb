class ArmchairAnalysis::Fumble < ActiveRecord::Base
  belongs_to :play, {
    foreign_key: :pid,
    primary_key: :pid
  }

  has_one :game, through: :play

  has_one :recovered_by, {
    primary_key: :frcv,
    foreign_key: :armchair_analysis_id,
    class_name: '::Player'
  }

  has_one :forced_by, {
    primary_key: :forc,
    foreign_key: :armchair_analysis_id,
    class_name: '::Player'
  }

  has_one :fumbled_by, {
    primary_key: :fum,
    foreign_key: :armchair_analysis_id,
    class_name: '::Player'
  }
end
