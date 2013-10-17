class ProjectionsController < ApplicationController
  def index
    @week = (params[:week] || GameWeek.current).to_i
    where_clause = {week: @week}
    query = Projection.where(where_clause).paginate(page: params[:page], per_page: 50)
    
    query = query.where("standard > ?", params[:above]) if params[:above]
    query = query.where("standard < ?", params[:below]) if params[:below]
    if !params[:above] && !params[:below]
      query = query.where("standard != ? AND standard_high != ? and standard_low != ?", 0.0, 0.0, 0.0)
    end
    query = query.where("players.full_name LIKE ?", "%#{params[:name]}%") if params[:name]
    query = query.where("players.position" => params[:position].split(',')) if params[:position]
    query = query.where("players.team_abbr" => params[:team].split(',')) if params[:team]
    query = query.where("players.position_type" => params[:position_type].split(',')) if params[:position_type]
    query = query.where("players.owner_key" => params[:owner]) if params[:owner]
    query = query.where("players.ownership_type" => params[:ownership_type].split(',')) if params[:ownership_type]

    query = query.group("projections.fantasy_football_nerd_id").
      joins(:player).
      order(updated_at: :desc).order(rank: :asc)

    query = query.limit(params[:limit].to_i) if params[:limit]

    @projections = query
    
    response = fresh_when(etag: collection_etag(@projections, :week), :public => true)
    respond_to do |format|
      format.html {
        response
      }
      format.js {
        response
      }
    end
  end
end
