class PlayersController < ApplicationController
  before_action :set_player, only: :show

  def index
    query = Projection.
      where(week: GameWeek.current.week).
      joins(:player).
      includes(:player).
      order(rank: :asc, updated_at: :desc).
      group(:fantasy_football_nerd_id)

    query = query.where("players.full_name LIKE ?", "%#{params[:name]}%") if params[:name]

    @projections = query.limit(params[:limit] || 100).load
  end

  def typeahead
    attributes = [:full_name, :headshot, :team_abbr, :id]
    results = if query = params[:query]
      clause = "%#{query}%"
      Player.where("first_name LIKE :name OR last_name LIKE :name OR full_name LIKE :name", {name: clause}).
        joins(:points).
        group('players.id').
        order('SUM(player_point_totals.total) DESC').
        select(attributes).limit(10)
    else
      Player.where { fantasy_football_nerd_id != nil }.
        joins(:points).
        group('players.id').
        order('SUM(player_point_totals.total) DESC').
        select(attributes)
    end

    players = results.map do |player|
      {
        team: player.team_abbr_long,
        id: player.id,
        value: player.full_name,
        tokens: player.full_name.split,
        headshot: player.headshot
      }
    end
    render json: players.to_json
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
