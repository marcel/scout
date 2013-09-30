class PlayerPointTotalsController < ApplicationController
  before_action :set_player_with_points, only: :show

  def index
    @week = params[:week] || GameWeek.current.week
    
    query = PlayerPointTotal.
      where(week: @week).
      includes(:player).
      joins(:player)
    
    query = query.where("players.position" => params[:position].split(',')) if params[:position]
    query = query.where("players.team_abbr" => params[:team].split(',')) if params[:team]
    query = query.where("players.position_type" => params[:position_type].split(',')) if params[:position_type]
    
    @player_point_totals = query.
      order(total: :desc).
      limit(params[:limit] || 100)
  end

  def show
  end

  private
    def set_player_with_points
      @player = Player.where(id: params[:player_id]).includes(:points).first
    end
end
