class PlayersController < ApplicationController
  before_action :set_player, only: :show
  
  def index        
    query = Projection.
      where(week: GameWeek.current.week).
      joins(:player).
      includes(:player).
      order(rank: :asc, updated_at: :desc).
      group("projections.fantasy_football_nerd_id")
  
    query = query.where("players.full_name LIKE ?", "%#{params[:name]}%") if params[:name]
    
    
    @projections = query.limit(params[:limit] || 100).load
  end

  def show
  end
  
  def search
    @players = Player.where("full_name LIKE ?", "%#{params[:search]}%").load
  end

  private
    def set_player
      @player = Player.find(params[:id])
    end
end
