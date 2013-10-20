class WatchController < ApplicationController
  def index
    query = current_account.watches.joins(:player).includes(:player)

    query = query.where("players.full_name LIKE ?", "%#{params[:name]}%") if params[:name]
    query = query.where("players.position" => params[:position].split(',')) if params[:position]
    query = query.where("players.team_abbr" => params[:team].split(',')) if params[:team]
    query = query.where("players.position_type" => params[:position_type].split(',')) if params[:position_type]
    query = query.where("players.owner_key" => params[:owner]) if params[:owner]
    query = query.where("players.ownership_type" => params[:ownership_type].split(',')) if params[:ownership_type]

    @watches = query.load.sort_by do |watch|
      [-watch.votes, -watch.player.total_points]
    end
  end

  def update
    if watch = current_account.watches.where(player_id: params[:id]).take
      if params[:upvote]
        watch.votes += Integer(params[:upvote])
        watch.save
      else
        watch.destroy
      end
    else
      current_account.watches.create(player_id: params[:id])
    end

    render nothing: true
  end
end
