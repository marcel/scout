class ArmchairAnalysis::FirstDown < ActiveRecord::Base
  belongs_to :play, {
    class_name: 'ArmchairAnalysis::Play',
    primary_key: :pid,
    foreign_key: :pid
  }

  has_one :game, through: :play

  has_one :offense, through: :play
  has_one :defense, through: :play
end
