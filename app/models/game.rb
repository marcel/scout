class Game < ActiveRecord::Base
  has_one :outcome, ->(game) {
    where(wk: game.week, v: game.away.armchair_analysis_team_name, h: game.home.armchair_analysis_team_name)
  }, class_name: 'ArmchairAnalysis::Game', primary_key: :week, foreign_key: :wk

  has_one :home, -> {where position: 'DEF'}, {
    primary_key: :home_team,
    foreign_key: :team_abbr,
    class_name: '::Player'
  }

  has_one :away, -> {where position: 'DEF'}, {
    primary_key: :away_team,
    foreign_key: :team_abbr,
    class_name: '::Player'
  }

  def home_defense_overall_matchup_score
    (
      m(home_defense_turnover_score, home_defense_sack_score, away_offense_points_scored_against_by_opposing_defense_score)
    ).round(1)
  end

  def away_defense_overall_matchup_score
    (
      m(away_defense_turnover_score, away_defense_sack_score, home_offense_points_scored_against_by_opposing_defense_score)
    ).round(1)
  end

  def home_defense_turnover_score
    Math.log2(m(home_defense_interception_score, home_defense_fumble_score)).round(1)
  end

  def away_defense_turnover_score
    Math.log2(m(away_defense_interception_score, away_defense_fumble_score)).round(1)
  end

  def home_defense_interception_score
    Math.log2(m(home.cached_interceptions.size, away.cached_intercepted.size)).round(1)
  end

  def away_defense_interception_score
    Math.log2(m(away.cached_interceptions.size, home.cached_intercepted.size)).round(1)
  end

  def home_defense_fumble_score
    Math.log2(m(home.cached_recovered_fumbles.size, away.cached_game_performances_for_team.map(&:fum).sum)).round(1)
  end

  def away_defense_fumble_score
    Math.log2(m(away.cached_recovered_fumbles.size, home.cached_game_performances_for_team.map(&:fum).sum)).round(1)
  end

  def home_defense_sack_score
    Math.log2(
      m(
        home.cached_game_performances_for_team.map(&:lbs).sum + home.cached_game_performances_for_team.map(&:dbs).sum,
        away.cached_game_performances_for_team.map(&:sk).sum
      )
    ).round(1)
  end

  def away_defense_sack_score
    Math.log2(
      m(
        away.cached_game_performances_for_team.map(&:lbs).sum + away.cached_game_performances_for_team.map(&:dbs).sum,
        home.cached_game_performances_for_team.map(&:sk).sum
      )
    ).round(1)
  end

  def home_offense_points_scored_score
    Math.log2(home.cached_game_performances_for_team.map(&:pts).sum).round(1)
  end

  def home_offense_points_scored_against_by_opposing_defense_score
    [0.0, Math.log2(home.cached_game_performances_by_opponents.map(&:dp).sum).round(1)].max
  end

  def away_offense_points_scored_score
    Math.log2(away.cached_game_performances_for_team.map(&:pts).sum).round(1)
  end

  def away_offense_points_scored_against_by_opposing_defense_score
    [0.0, Math.log2(away.cached_game_performances_by_opponents.map(&:dp).sum).round(1)].max
  end

  private
    def m(*args)
      if args.all?(&:zero?)
        0.0
      else
        args.delete_if(&:zero?).inject(:*)
      end
    end
end
