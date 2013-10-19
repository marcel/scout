class MatchupsController < ApplicationController
  def index
    @week = (params[:week] || GameWeek.current.week).to_i
    @defensive_matchups = Game.where(week: @week).includes(:home, :away, :stadium).load.map do |game|
        [game.home_team_defensive_matchup, game.away_team_defensive_matchup]
    end.flatten.sort_by(&sort_function)

    minmax = ->(attribute) { @defensive_matchups.map(&attribute).minmax }

    @overall_matchup_score_value_bucket = RelativePerformanceValueBucket.new(
      *minmax.(:overall_matchup_score)
    )

    @points_scored_value_bucket = RelativePerformanceValueBucket.new(
      *minmax.(:points_scored_score)
    )

    @turnover_score_value_bucket = RelativePerformanceValueBucket.new(
      *minmax.(:turnover_score)
    )

    @interception_score_value_bucket = RelativePerformanceValueBucket.new(
      *minmax.(:interception_score)
    )

    @fumble_score_value_bucket = RelativePerformanceValueBucket.new(
      *minmax.(:fumble_score)
    )

    @sack_score_value_bucket = RelativePerformanceValueBucket.new(
      *minmax.(:sack_score)
    )

    @opposing_offense_points_scored_score_value_bucket = RelativePerformanceValueBucket.new(
      *minmax.(:offense_points_scored_score)
    )
    @opposing_offense_points_scored_score_value_bucket.buckets.reverse!

    @forecast_score_value_bucket = RelativePerformanceValueBucket.new(
      *minmax.(:forecast_score)
    )

    fresh_when(etag: collection_etag(@defensive_matchups, :week), :public => true)
  end

  def sort_function
    ->(matchup) {
      case params[:sort]
      when 'm'
        -matchup.overall_matchup_score
      when 'p'
        -matchup.points_scored_score
      when 't'
        -matchup.turnover_score
      when 'i'
        -matchup.interception_score
      when 'f'
        -matchup.fumble_score
      when 's'
        -matchup.sack_score
      when 'o'
        matchup.offense_points_scored_score
      when 'w'
        -matchup.forecast_score
      else
        -matchup.overall_matchup_score
      end
    }
  end

  class ValueBucket
    attr_reader :min, :max, :chunk_size, :max_index, :buckets
    def initialize(min, max, buckets)
      @min        = min
      @max        = max
      @buckets    = buckets
      @chunk_size = (max.to_f - min) / buckets.size
      @chunk_size = 1 if @chunk_size.zero?
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
