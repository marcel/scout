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

  # def forecast
  #   @forecast ||= Rails.cache.fetch(['game-forecast', cache_key], expires_in: 6.hours) {
  #     ForecastIO.forecast(
  #       stadium.latitude,
  #       stadium.longitude,
  #       time: (date.to_time.utc + 12.hours).to_i,
  #       params: {exclude: 'currently,flags,alerts'}
  #     ).hourly.data[kickoff_time.hour]
  #   }
  # end

  def forecast
    return @forecast if defined?(@forecast)
    @forecast = Rails.cache.fetch(['game-forecast', cache_key], expires_in: 3.hours) {
      HAMWeatherClient.forecast(
        [stadium.latitude, stadium.longitude].join(','),
        from: date.to_time.to_i,
        to: '+4hours'
      ).try(:response).try(:first).try(:periods).try(:first)
    end
  end

  class HAMWeatherClient
    API_ROOT = 'https://api.aerisapi.com'
    class << self
      attr_accessor :default_params, :default_connection

      def forecast(*args, &block)
        self.default_connection ||= new
        default_connection.forecast(*args, &block)
      end
    end

    self.default_params = {client_id: 'YkJmrOXJHqCkx5Ymuo7o8', client_secret: '9VsoAaq6r8b7DkgnID0G5DXg0TEMEx4bJ1F8Samw'}

    def forecast(id, params = {})
      forecast_url = File.join(API_ROOT, 'forecasts', id.to_s)

      forecast_response = get(forecast_url, params)

      if forecast_response.success?
        Hashie::Mash.new(MultiJson.load(forecast_response.body))
      end
    end

    def connection
      @connection ||= Faraday.new do |builder|
        builder.adapter :typhoeus
        builder.use Faraday::Response::Logger
      end
    end

    private

    def get(path, params = {})
      params = self.class.default_params.merge(params || {})

      connection.get(path, params)
    end
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

    def home_team?
      defense.team_abbr == game.home_team
    end

    def boost(score, amount)
      (score * amount * home_field_advantage_score).round(1)
    end

    def overall_matchup_score
      score((m(
        boost(points_scored_score, 7),
        boost(turnover_score, 5),
        boost(sack_score, 3),
      ) / boost(offense_points_scored_score, 10)))#.round(1)
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
      # score(
        m(
          defense.cached_game_performances_for_team.map(&:lbs).sum + defense.cached_game_performances_for_team.map(&:dbs).sum,
          offense.cached_game_performances_for_team.map(&:sk).sum
        )
      # )
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
