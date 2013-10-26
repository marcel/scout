class ArmchairAnalysis::Play < ActiveRecord::Base
  self.inheritance_column = nil

  scope :carries, -> { joins(:carry) }
  scope :passes, -> { joins(:pass) }
  scope :in_redzone, ->(within = 5) { where("#{table_name}.yfog >= ?", 100 - within) }
  scope :completions, -> { joins(:completions) }
  scope :first_downs, -> { joins(:first_downs) }
  scope :fumbles, -> { joins(:fumble) }
  scope :two_point_conversions, -> { joins(:two_point_conversion) }
  scope :scoring_plays, -> { joins(:scoring_play) }

  scope :on_week, ->(week) { joins(:game).where(ArmchairAnalysis::Game.arel_table[:wk].eq(week)) }

  has_one :scoring_play, {
    foreign_key: :pid,
    primary_key: :pid
  }

  has_one :fumble, {
    foreign_key: :pid,
    primary_key: :pid
  }

  has_one :pass, {
    foreign_key: :pid,
    primary_key: :pid
  }

  has_one :carry, {
    foreign_key: :pid,
    primary_key: :pid,
    class_name: 'ArmchairAnalysis::Rush'
  }

  has_one :two_point_conversion, {
    foreign_key: :pid,
    primary_key: :pid,
    class_name: 'ArmchairAnalysis::Conversion'
  }

  has_many :completions, {
    foreign_key: :pid,
    primary_key: :pid
  }

  belongs_to :game, {
    primary_key: :gid,
    foreign_key: :gid
  }

  has_many :first_downs, {
    primary_key: :pid,
    foreign_key: :pid,
    class_name: 'ArmchairAnalysis::FirstDown'
  }

  belongs_to :offense, ->{ where(position: 'DEF') }, {
    primary_key: :armchair_analysis_team_name,
    foreign_key: :off,
    class_name: '::Player'
  }

  belongs_to :defense, ->{ where(position: 'DEF') }, {
    primary_key: :armchair_analysis_team_name,
    foreign_key: :def,
    class_name: '::Player'
  }
end