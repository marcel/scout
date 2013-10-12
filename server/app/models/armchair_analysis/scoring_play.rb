class ArmchairAnalysis::ScoringPlay < ActiveRecord::Base
  belongs_to :play, {
    primary_key: :pid,
    foreign_key: :pid,
    class_name: 'ArmchairAnalysis::Play'
  }
end
