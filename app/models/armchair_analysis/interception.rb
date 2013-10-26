class ArmchairAnalysis::Interception < ActiveRecord::Base
  belongs_to :play, {
    primary_key: :pid,
    foreign_key: :pid
  }

  has_one :game, through: :play

  has_one :intercepted_by, {
    foreign_key: :armchair_analysis_id,
    primary_key: :int,
    class_name: '::Player'
  }
end
