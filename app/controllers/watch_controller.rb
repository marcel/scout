class WatchController < ApplicationController
  def index
    query = Player.joins(:watches).
      includes(:watches, :points, :projections)
    
    query = query.where("players.full_name LIKE ?", "%#{params[:name]}%") if params[:name]
    query = query.where(position: params[:position].split(',')) if params[:position]
    query = query.where(team_abbr: params[:team].split(',')) if params[:team]
    query = query.where(position_type: params[:position_type].split(',')) if params[:position_type]
    query = query.where(owner_key: params[:owner]) if params[:owner]
    query = query.where(ownership_type: params[:ownership_type].split(',')) if params[:ownership_type]
      
    @players = query.load.sort_by do |player| 
      [-player.watches.first.votes, -player.total_points]
    end
  end
  
  def update
    if watch = Watch.where(player_id: params[:id]).take
      if params[:upvote]
        watch.votes += Integer(params[:upvote])
        watch.save
      else
        watch.destroy
      end
    else
      Watch.create(player_id: params[:id])
    end
    
    render nothing: true
  end
end
