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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_params
      params[:player]
    end
end
