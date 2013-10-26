class ArmchairAnalysis::FieldGoalExtraPoint < ActiveRecord::Base
  scope :made, -> { where(good: 'Y') }
  scope :missed, -> { where(good: 'N') }

  scope :field_goals, -> { where(fgxp: 'FG') }
  scope :extra_points, -> { where(fgxp: 'XP') }
  scope :longest, -> { order(dist: :desc).limit(1) }


  belongs_to :play, {
    class_name: 'ArmchairAnalysis::Play',
    primary_key: :pid,
    foreign_key: :pid
  }

  has_one :game, through: :play

  belongs_to :player, {
    class_name: '::Player',
    primary_key: :armchair_analysis_id,
    foreign_key: :fkicker
  }

  def made?
    good == 'Y'
  end

  def missed?
    !made?
  end
end
