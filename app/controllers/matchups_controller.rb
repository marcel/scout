class MatchupsController < ApplicationController
  def index
    @week = (params[:week] || GameWeek.current.week).to_i
    @games = Game.where(week: @week).includes(:home, :away).load.sort_by do |game|
      -[game.home_defense_overall_matchup_score, game.away_defense_overall_matchup_score].max
    end

    @overall_matchup_score_value_bucket = RelativePerformanceValueBucket.new(
      *(@games.map(&:home_defense_overall_matchup_score) + @games.map(&:away_defense_overall_matchup_score)).minmax
    )

    @turnover_score_value_bucket = RelativePerformanceValueBucket.new(
      *(@games.map(&:home_defense_turnover_score) + @games.map(&:away_defense_turnover_score)).minmax
    )

    @interception_score_value_bucket = RelativePerformanceValueBucket.new(
      *(@games.map(&:home_defense_interception_score) + @games.map(&:away_defense_interception_score)).minmax
    )

    @fumble_score_value_bucket = RelativePerformanceValueBucket.new(
      *(@games.map(&:home_defense_fumble_score) + @games.map(&:away_defense_fumble_score)).minmax
    )

    @sack_score_value_bucket = RelativePerformanceValueBucket.new(
      *(@games.map(&:home_defense_sack_score) + @games.map(&:away_defense_sack_score)).minmax
    )

    @opposing_offense_points_scored_score_value_bucket = RelativePerformanceValueBucket.new(
      *(@games.map(&:home_offense_points_scored_score) + @games.map(&:away_offense_points_scored_score)).minmax
    )
    @opposing_offense_points_scored_score_value_bucket.buckets.reverse!
  end

  class ValueBucket
    attr_reader :min, :max, :chunk_size, :max_index, :buckets
    def initialize(min, max, buckets)
      @min        = min
      @max        = max
      @buckets    = buckets
      @chunk_size = (max.to_f - min) / buckets.size
      @max_index  = buckets.size - 1
    end

    def [](value)
      index = ((max - (max-value+min)) / chunk_size).ceil - 1
      bounded_index = [[index, 0].max, max_index].min
      buckets[bounded_index]
    end
  end

  class RelativePerformanceValueBucket < ValueBucket
    BUCKETS = %w[important warning primary info success]

    def initialize(min, max)
      super(min, max, BUCKETS.dup)
    end
  end
end
