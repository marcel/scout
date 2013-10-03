class ProjectionsController < ApplicationController
  before_action :set_projection, only: [:show, :edit, :update, :destroy]

  def index
    @week = params[:week] || GameWeek.current.week
    where_clause = {week: @week}    
    query = Projection.where(where_clause)
    query = query.where("standard > ?", params[:above]) if params[:above]
    query = query.where("standard < ?", params[:below]) if params[:below]
    query = query.where("players.full_name LIKE ?", "%#{params[:name]}%") if params[:name]
    query = query.where("players.position" => params[:position].split(',')) if params[:position]
    query = query.where("players.team_abbr" => params[:team].split(',')) if params[:team]
    query = query.where("players.position_type" => params[:position_type].split(',')) if params[:position_type]
    query = query.where("players.owner_key" => params[:owner]) if params[:owner]
    query = query.where("players.ownership_type" => params[:ownership_type].split(',')) if params[:ownership_type]
        
    query = query.
      joins(:player).
      order(updated_at: :desc).order(rank: :asc).
      group("projections.fantasy_football_nerd_id").
      distinct.
      includes(:player)
      
    query = query.limit(params[:limit]) if params[:limit]
    
    @projections = query
  end

  def show
  end

  private
    def set_projection
      @projection = Projection.find(params[:id])
    end
end
