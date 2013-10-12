class ArmchairAnalysis::Completion < ActiveRecord::Base
  belongs_to :pass, {
    primary_key: :pid,
    foreign_key: :pid
  }
end
