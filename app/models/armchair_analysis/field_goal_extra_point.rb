class ArmchairAnalysis::FieldGoalExtraPoint < ActiveRecord::Base
  belongs_to :play, {
    class_name: 'ArmchairAnalysis::Play',
    primary_key: :pid,
    foreign_key: :pid
  }

  has_one :game, through: :play

  def made?
    good == 'Y'
  end

  def missed?
    !made?
  end
end
