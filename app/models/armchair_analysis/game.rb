class ArmchairAnalysis::Game < ActiveRecord::Base
  has_many :plays, {
    foreign_key: :gid,
    primary_key: :gid
  }

  has_many :drives, {
    foreign_key: :gid,
    primary_key: :gid,
    class_name: 'ArmchairAnalysis::Drive'
  }

  has_many :redzone_opportunities, {
    primary_key: :gid,
    foreign_key: :gid
  }

  has_one :stadium, {
    primary_key: :h,
    foreign_key: :armchair_analysis_team_name
  }

  def won_by_home_team?
    ptsh > ptsv
  end

  def won_by_away_team?
    !won_by_home_team?
  end
end
