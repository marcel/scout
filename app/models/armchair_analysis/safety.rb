class ArmchairAnalysis::Safety < ActiveRecord::Base
  belongs_to :play, {
    foreign_key: :pid,
    primary_key: :pid
  }

  has_one :game, through: :play
end
