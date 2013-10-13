class PlayerPointTotalsController < ApplicationController
  before_action :set_player_with_points, only: :show
  
  def index
    @week = (params[:week] || GameWeek.current.week).to_i
    
    query = PlayerPointTotal.
      where(week: @week).
      includes(:player).
      joins(:player)
    
    @player_point_totals = apply_filters(query).
      order(total: :desc).
      limit(params[:limit] || 100)
  end
  
  def season
    @no_sidebar = true # TODO Do this is a non-janky way
    
    params[:position] ||= 'QB'
    
     query = PlayerPointTotal.where.not(total: 0.0).
      joins(:player).
      includes(:player)
      
      @player_point_totals = apply_filters(query).load.group_by(&:player)
  end
  
  def defense
    query = Player.defense.
      includes(:points, :watches, :owner, :game_performances_for_team => :game)
    
    if params[:week]
      @week = params[:week].to_i
      query = query.where("armchair_analysis_games.wk" => @week) 
      query = query.where("player_point_totals.week" => @week)
    end
    
    @players = apply_filters(query).sort_by(&defense_sort_function)
  end
  
  def offense
    query = Player.defense.
      includes(:points, :watches, :owner, :game_performances_for_team => :game)

    if params[:week]
      @week = params[:week].to_i
      query = query.where("armchair_analysis_games.wk" => @week) 
      query = query.where("player_point_totals.week" => @week)
    end

    @players = apply_filters(query).sort_by(&offense_sort_function)
  end
  
  def offense_sort_function
    ->(player) {
      case params[:sort]
      when 'p'
        -player.game_performances_for_team.map(&:pts).sum
      when 'pa'
        player.game_performances_for_team.by_opponents.map(&:pts).sum
      when 'ry'
        -player.game_performances_for_team.map(&:ry).sum 
      when 'py'
        -player.game_performances_for_team.map(&:py).sum
      else
        -player.game_performances_for_team.map(&:pts).sum
      end
    }
  end
  
  def defense_sort_function
    ->(player) {
      case params[:sort]
      when 'fp'
        -player.points.map(&:total).sum
      when 'p'
        -player.game_performances_for_team.map(&:dp).sum
      when 'pa'
        opponent_performances = player.game_performances_for_team.by_opponents

        opponent_performances.map(&:pts).sum - opponent_performances.map(&:dp).sum
      when 'ry'
        player.game_performances_for_team.by_opponents.map(&:ry).sum
      when 'py'
        player.game_performances_for_team.by_opponents.map(&:py).sum
      else
        -player.points.map(&:total).sum
      end
    }
  end
  
  def targets
    @week = (params[:week] || GameWeek.current.week).to_i
    
    query = ArmchairAnalysis::Offense.joins(:player).
      joins(:game_in_season).
      where(armchair_analysis_games: {wk:  @week}).where("armchair_analysis_offenses.trg > 0").
      order(trg: :desc)
      
    @offensive_performances = apply_filters(query).load
  end
  
  def carries
    @week = (params[:week] || GameWeek.current.week).to_i

    query = ArmchairAnalysis::Offense.joins(:player).
      joins(:game_in_season).
      where(armchair_analysis_games: {wk:  @week}).where("ra > 0").
      order(ra: :desc)

    @offensive_performances = apply_filters(query).load
  end

  def show
  end
  
  def positions
  end

  private
    def apply_filters(query)
      if params[:name]
        names = params[:name].split(',').map {|name| "%#{name}%"}
        clause = (["players.full_name LIKE ?"] * names.size).join(' OR ')
        query = query.where(clause, *names)
      end
      
      query = query.joins(:player => :watches) if params[:watched]
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
    
    def set_player_with_points
      @player = Player.where(id: params[:player_id]).includes(:points, :projections, :offensive_performances => [:game_in_season]).first
    end
end
