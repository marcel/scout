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

  has_one :stadium, {
    primary_key: :home_team,
    foreign_key: :team_abbr
  }

  has_one :game_forecast
  
  class << self
    def update_forecasts(week = GameWeek.current.week)
      STDERR.puts "[#{Time.zone.now}] Updating weather forecasts for week #{week}"
      where(week: week).includes(:stadium).each(&:forecast)
    end
  end

  # TODO Just fix kickoff_time so you don't need both colums
  def start_time
    date.to_time + kickoff_time.hour.hours
  end

  def forecast
    return @forecast if defined?(@forecast)
    @forecast = Scout.cache.fetch(['game-forecast', cache_key], expires_in: rand(30..60).minutes) {
      if start_time > Time.zone.now
        if payload = Scout.weather.forecast(
            [stadium.latitude, stadium.longitude].join(','),
            from: start_time.to_i,
            to: '+4hours'
          )

          game_forecast = GameForecast.find_or_initialize_by(game_id: id)
          game_forecast.attributes = GameForecast.attributes_from_payload(payload)
          game_forecast.save if game_forecast.changed?
          game_forecast
        end
      else
        game_forecast
      end
    }
  end

  def home_team?(team)
    home_team == team.team_abbr
  end

  def away_team?(team)
    !home_team?
  end

  def home_team_defensive_matchup
    @home_team_defensive_matchup ||= DefensiveMatchup.new(self, home, away)
  end

  def away_team_defensive_matchup
    @away_team_defensive_matchup ||= DefensiveMatchup.new(self, away, home)
  end

  class DefensiveMatchup
    attr_reader :game, :defense, :offense
    def initialize(game, defense, offense)
      @game    = game
      @defense = defense
      @offense = offense
    end

    def cache_key
      [game, defense, offense].map(&:cache_key).join("/")
    end

    def home_team?
      defense.team_abbr == game.home_team
    end

    def boost(score, amount)
      (score * amount * home_field_advantage_score).round(1)
    end

    def overall_matchup_score
      score((m(
        boost(points_scored_score, 100),
        boost(turnover_score, 50),
        boost(sack_score, 20),
        boost(forecast_score, 10)
      ) / boost(offense_points_scored_score, 75)))
    end

    def points_scored_score
      m(
        defense.cached_game_performances_for_team.map(&:dp).sum,
        offense.cached_game_performances_by_opponents.map(&:dp).sum
      )
    end

    def home_field_advantage_score
      home_team? ? 1.1 : 0.9
    end

    def forecast_score
      if game.stadium.open_air? && forecast = game.forecast
        temperature  = forecast.temp_feels_like >= 50 ? forecast.temp_feels_like : 130 - forecast.temp_feels_like
        temperature *= 10
        score(forecast.severity * temperature)
      else
        1
      end
    end

    def turnover_score
      interception_score + fumble_score
    end

    def interception_score
      m(defense.cached_interceptions.size, offense.cached_intercepted.size)
    end

    def fumble_score
      m(defense.cached_recovered_fumbles.size, offense.cached_game_performances_for_team.map(&:fum).sum)
    end

    def sack_score
      m(
        defense.cached_game_performances_for_team.map(&:lbs).sum + defense.cached_game_performances_for_team.map(&:dbs).sum,
        offense.cached_game_performances_for_team.map(&:sk).sum
      )
    end

    def offense_points_scored_score
      m(offense.cached_game_performances_for_team.map(&:pts).sum)
    end

    private
      def score(value)
        Math.log2(value).round(1)
      end

      def m(*args)
        if args.all?(&:zero?)
          1
        else
          args.delete_if(&:zero?).inject(:*)
        end
      end
  end
end
