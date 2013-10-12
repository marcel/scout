class ArmchairAnalysis::FieldGoalExtraPoint < ActiveRecord::Base
  belongs_to :play, {
    class_name: 'ArmchairAnalysis::Play',
    primary_key: :pid,
    foreign_key: :pid
  }
end
