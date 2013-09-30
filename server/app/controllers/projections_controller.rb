class ProjectionsController < ApplicationController
  before_action :set_projection, only: [:show, :edit, :update, :destroy]

  def index
    @week = params[:week] || GameWeek.current.week
    where_clause = {week: @week}    
    projections = Projection.where(where_clause)
    projections = projections.where("standard > ?", params[:above]) if params[:above]
    projections = projections.where("standard < ?", params[:below]) if params[:below]
    projections = projections.where("players.full_name LIKE ?", "%#{params[:name]}%") if params[:name]
    
    projections = projections.where("players.position" => params[:position].split(',')) if params[:position]
    projections = projections.where("players.team_abbr" => params[:team].split(',')) if params[:team]
    projections = projections.where("players.position_type" => params[:position_type].split(',')) if params[:position_type]
    
    projections = projections.
      joins(:player).
      order(updated_at: :desc).order(rank: :asc).
      group("projections.fantasy_football_nerd_id").
      distinct.
      includes(:player)
      
    projections = projections.limit(params[:limit]) if params[:limit]
    
    @projections = projections
  end

  def show
  end

  private
    def set_projection
      @projection = Projection.find(params[:id])
    end
end
