class InjuriesController < ApplicationController
  before_action :set_injury, only: :show

  def index
    @week = (params[:week] || GameWeek.current.week).to_i
    where_clause = {week: @week}

    # where_clause.update(game_status: params[:game_status]) if params[:game_status]
    where_clause.update(injury: params[:injury]) if params[:injury]
    where_clause.update(practice_status: params[:practice_status]) if params[:practice_status]

    query = Injury.where(where_clause)
    query = query.where("players.full_name LIKE ?", "%#{params[:name]}%") if params[:name]
    query = query.where("players.owner_key" => params[:owner]) if params[:owner]

    query = query.where("players.position" => params[:position].split(',')) if params[:position]
    query = query.where("players.team_abbr" => params[:team].split(',')) if params[:team]
    query = query.where("players.position_type" => params[:position_type].split(',')) if params[:position_type]

    if params[:game_status]
      if player_status = Player::PlayingStatus.lookup(params[:game_status])
        query = query.where(
          "injuries.game_status = ? OR players.playing_status = ?",
          player_status.display_name,
          player_status.abbreviation
        )
      end
    end

    @injuries = query.
      joins(:player).
      order(last_update: :desc)
    @injuries = @injuries.sort_by {|injury| -injury.cached_player.cached_points.map(&:total).sum } if params[:sort].to_s == 'p'
  end

  def show
  end

  private
    def set_injury
      @injury = Injury.includes(:player).find(params[:id])
    end

    def injury_params
      params[:injury]
    end
end
