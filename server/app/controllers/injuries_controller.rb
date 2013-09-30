class InjuriesController < ApplicationController
  before_action :set_injury, only: :show

  def index
    @week = params[:week] || GameWeek.current.week
    where_clause = {week: @week}
    
    # where_clause.update(game_status: params[:game_status]) if params[:game_status]
    where_clause.update(injury: params[:injury]) if params[:injury]
    where_clause.update(practice_status: params[:practice_status]) if params[:practice_status]
    
    query = Injury.where(where_clause)
    query = query.where("players.full_name LIKE ?", "%#{params[:name]}%") if params[:name]
    
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
      includes(:player).
      order(last_update: :desc)
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
