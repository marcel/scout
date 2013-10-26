class ArmchairAnalysis::Pass < ActiveRecord::Base
  SHORT_MIDDLE = 'SM'
  SHORT_LEFT   = 'SL'
  SHORT_RIGHT  = 'SR'

  DEEP_MIDDLE  = 'DM'
  DEEP_LEFT    = 'DL'
  DEEP_RIGHT   = 'DR'
  {
    short_middle: SHORT_MIDDLE, short_left: SHORT_LEFT, short_right: SHORT_RIGHT,
    deep_middle: DEEP_MIDDLE, deep_left: DEEP_LEFT, deep_right: DEEP_RIGHT
  }.each do |location, abbreviation|
    scope location, -> { where(loc: abbreviation) }
  end

  scope :short, -> { where(loc: [SHORT_LEFT, SHORT_MIDDLE, SHORT_RIGHT]) }
  scope :deep, -> { where(loc: [DEEP_LEFT, DEEP_MIDDLE, DEEP_RIGHT]) }

  scope :in_redzone, ->(within = 5) {
    joins(:play).merge(ArmchairAnalysis::Play.in_redzone(within))
  }

  scope :gaining_yardage_of_at_least, ->(distance) { where("yds >= ?", distance) }
  scope :completions, -> { joins(:completion) }
  scope :receptions, -> { completions }
  scope :scoring_plays, -> { joins(:scoring_play) }
  scope :with_highest_value_fantasy_point_values, -> { scoring_plays.order(yds: :desc) }
  scope :interceptions, -> { joins(:interception)}

  scope :by_team, ->(team) {
    joins(:receiver).where("players.team_abbr" => team)
  }

  scope :successful_plays, -> {
    joins(:successful_play)
  }

  belongs_to :successful_play, {
    primary_key: :pid,
    foreign_key: :pid
  }

  belongs_to :completion, {
    foreign_key: :pid,
    primary_key: :pid
  }

  has_one :interception, {
    foreign_key: :pid,
    primary_key: :pid
  }

  belongs_to :play, {
    foreign_key: :pid,
    primary_key: :pid
  }

  belongs_to :scoring_play, {
    foreign_key: :pid,
    primary_key: :pid
  }

  has_one :passer, {
    foreign_key: :armchair_analysis_id,
    primary_key: :psr,
    class_name: '::Player'
  }

  has_one :receiver, {
    foreign_key: :armchair_analysis_id,
    primary_key: :trg,
    class_name: '::Player'
  }

  has_one :game, :through => :play

  # TODO Do receivers also get 2 point conversion points? If so add that
  def receiver_fantasy_points
    receiver_yardage_fantasy_points + receiver_touchdown_fantasy_points
  end

  def receiver_yardage_fantasy_points
    yds / 10.0 # TODO Ultimately this needs to be computed based on league settings but for now I'm hardcoding
  end

  def receiver_touchdown_fantasy_points
    scoring_play.nil? ? 0 : 6
  end

  # TODO Add 2 point conversion points
  def passing_fantasy_points
    passing_yardage_fantasy_points + passing_touchdown_fantasy_points + passing_interception_fantasy_points
  end

  def passing_yardage_fantasy_points
    yds / 25.0
  end

  def passing_touchdown_fantasy_points
    scoring_play.nil? ? 0 : 4
  end

  def passing_interception_fantasy_points
    interception.nil? ? 0 : -1
  end
end
