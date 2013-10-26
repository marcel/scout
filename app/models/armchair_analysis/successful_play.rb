class ArmchairAnalysis::SuccessfulPlay < ActiveRecord::Base
  belongs_to :play, {
    primary_key: :pid,
    foreign_key: :pid
  }

  has_one :game, through: :play

  has_one :offense, through: :play
  has_one :defense, through: :play
end
