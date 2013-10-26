class ArmchairAnalysis::Rush < ActiveRecord::Base
  scope :in_redzone, ->(within = 5) {
    joins(:play).merge(ArmchairAnalysis::Play.in_redzone(within))
  }

  scope :by_team, ->(team) {
    joins(:ball_carrier).where("players.team_abbr" => team)
  }

  scope :scoring_plays, -> {
    joins(:scoring_play)
  }

  scope :successful_plays, -> {
    joins(:successful_play)
  }

  belongs_to :successful_play, {
    primary_key: :pid,
    foreign_key: :pid
  }

  belongs_to :play, {
    primary_key: :pid,
    foreign_key: :pid
  }

  has_one :fumble, through: :play

  has_one :game, through: :play

  belongs_to :ball_carrier, {
    primary_key: :armchair_analysis_id,
    foreign_key: :bc,
    class_name: '::Player'
  }

  has_one :scoring_play, {
    primary_key: :pid,
    foreign_key: :pid,
    class_name: 'ArmchairAnalysis::ScoringPlay'
  }

  # TODO Left as a reminder, this is how I computed top redzone by player
  # ArmchairAnalysis::Rush.joins(:play).where("armchair_analysis_plays.zone" => 5).where("yfog >= 95").group("bc").count.sort_by {|k,v| -v }.map {|k,v| [(pl = Player.where(armchair_analysis_id: k).take; pl.try(:full_name)), (v.to_f / (pl.try(:carries).try(:count) || 1) * 100).round(1),  v, (pl ? (pl.redzone_carries.joins(:scoring_play).count.to_f / pl.redzone_carries.count * 100).round(1) : 0)]}.sort_by {|a,b,c, d| [-c, -d, -b.to_i] }
end