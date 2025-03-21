class PlayerPointTotalsController < ApplicationController
  def index
    @week  = (params[:week] ||= GameWeek.current.week).to_i
    @limit = (params[:limit] || 100).to_i
    query = PlayerPointTotal.
      where(week: @week).
      joins(:player)

    @player_point_totals = apply_filters(query).
      order(total: :desc).
      limit(@limit).sort_by(&points_sort_function)

    render_fresh(@player_point_totals, :week)
  end

  def points_sort_function
    ->(player_point_total) {
      player = player_point_total.cached_player
      case params[:sort]
      when 'p'
        -player_point_total.total
      when 'wa'
        -player.weekly_average_points
      when 'waxmax'
        -player.weekly_average_points_excluding_max
      when 'stdev'
        player.std_dev_of_points
      when 'max'
        -player.best_point_performance
      when 'min'
        -player.worst_point_performance
      else
        -player_point_total.total
      end
    }
  end

  def show
    @player = Player.where(id: params[:player_id]).take
    fresh_when(@player)
  end

  def season
    @no_sidebar = true # TODO Do this is a non-janky way

     query = PlayerPointTotal.where.not(total: 0.0).
      joins(:player).
      includes(:player)

    player_point_totals_by_player = apply_filters(query).load.group_by(&:player)

    data_points_per_player = player_point_totals_by_player.values.map(&:size).sort
    median_data_points = data_points_per_player[data_points_per_player.size / 2]
    @player_point_totals = player_point_totals_by_player.select {|k,v| v.size >= median_data_points}
  end

  def defense
    query = Player.defense

    if params[:week]
      # TODO Fix this. This doesn't work because the cached version is always loaded which
      # will always be all of them and this where clause is ignored.
      query = query.includes(:points, game_performances_for_team: :game)
      @week = params[:week].to_i
      query = query.where("armchair_analysis_games.wk" => @week)
      query = query.where("player_point_totals.week" => @week)
    end

    @players = apply_filters(query).sort_by(&defense_sort_function)
    render_fresh(@players, :week)
  end

  def offense
    query = Player.defense

    if params[:week]
      query = query.includes(:points, game_performances_for_team: :game)

      @week = params[:week].to_i
      query = query.where("armchair_analysis_games.wk" => @week)
      query = query.where("player_point_totals.week" => @week)
    end

    @players = apply_filters(query).sort_by(&offense_sort_function)
    render_fresh(@players, :week)
  end

  def offense_sort_function
    ->(player) {
      game_performances = player.cached_game_performances_for_team

      case params[:sort]
      when 'p'
        -game_performances.map(&:pts).sum
      when 'pa'
        player.cached_game_performances_by_opponents.map(&:pts).sum
      when 'ry'
        -game_performances.map(&:ry).sum
      when 'py'
        -game_performances.map(&:py).sum
      when 'int'
        player.cached_intercepted.size
      else
        -game_performances.map(&:pts).sum
      end
    }
  end

  def defense_sort_function
    ->(player) {
      opponent_performances = player.cached_game_performances_by_opponents

      case params[:sort]
      when 'fp'
        -player.total_points
      when 'p'
        -player.cached_game_performances_for_team.map(&:dp).sum
      when 'pa'
        opponent_performances.map(&:pts).sum - opponent_performances.map(&:dp).sum
      when 'ry'
        opponent_performances.map(&:ry).sum
      when 'py'
        opponent_performances.map(&:py).sum
      when 'int'
        -player.interceptions.size
      when 'rf'
        -player.cached_recovered_fumbles.map(&:frcv).sum
      when 't'
        -player.total_turnovers
      else
        -player.total_points
      end
    }
  end

  def targets
    @week = (params[:week] ||= GameWeek.current.week).to_i

    query = ArmchairAnalysis::Offense.joins(:player).
      joins(:game_in_season).
      where(armchair_analysis_games: {wk:  @week}).where("armchair_analysis_offenses.trg > 0").
      order(trg: :desc)

    @offensive_performances = apply_filters(query).sort_by(&targets_sort_function)
    render_fresh(@offensive_performances, :week)
  end

  def targets_sort_function
    ->(performance) {
      case params[:sort]
      when 'trg'
        -performance.trg
      when 'rec'
        -performance.rec
      when 'rz'
        -(performance.cached_redzone_opportunity.try(:trg) || 0)
      when 'recy'
        -performance.recy
      when 'tdre'
        -performance.tdre
      else
        -performance.trg
      end
    }
  end

  def carries
    @week = (params[:week] ||= GameWeek.current.week).to_i

    query = ArmchairAnalysis::Offense.joins(:player).
      joins(:game_in_season).
      where(armchair_analysis_games: {wk:  @week}).where("ra > 0").
      order(ra: :desc)

    @offensive_performances = apply_filters(query).sort_by(&carries_sort_function)
    render_fresh(@offensive_performances, :week)
  end

  def carries_sort_function
    ->(performance) {
      case params[:sort]
      when 'c'
        -performance.ra
      when 'rz'
        -(performance.cached_redzone_opportunity.try(:ra) || 0)
      when 'sr'
        -performance.sra
      when 'ry'
        -performance.ry
      when 'rcy'
        -performance.recy
      when 'rtd'
        -performance.tdr
      when 'rctd'
        -performance.tdre
      else
        -performance.ra
      end
    }
  end

  private
    def apply_filters(query)
      if params[:name]
        names = params[:name].split(',').map {|name| "%#{name}%"}
        clause = (["players.full_name LIKE ?"] * names.size).join(' OR ')
        query = query.where(clause, *names)
      end

      query = query.joins(:player => :watches) if params[:watched]
      query = query.where("players.owner_key" => params[:owner]) if params[:owner]
      query = query.where("players.position" => params[:position].split(',')) if params[:position]
      query = query.where("players.team_abbr" => params[:team].split(',')) if params[:team]
      query = query.where("players.position_type" => params[:position_type].split(',')) if params[:position_type]
      if params[:ownership_type]
        query = case params[:ownership_type]
          when 'available'
            query.where("players.owner_key IS NULL")
          when 'owned'
            query.where("players.owner_key IS NOT NULL")
          else
            query.where("players.ownership_type" => params[:ownership_type].split(','))
          end
      end

      query = query.limit(params[:limit].to_i) if params[:limit]
      query
    end
end
