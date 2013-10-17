class ArmchairAnalysis::Game < ActiveRecord::Base
  has_many :plays, {
    foreign_key: :gid,
    primary_key: :gid
  }

  has_many :redzone_opportunities, {
    primary_key: :gid,
    foreign_key: :gid
  }

  def won_by_home_team?
    ptsh > ptsv
  end

  def won_by_away_team?
    !won_by_home_team?
  end
end
