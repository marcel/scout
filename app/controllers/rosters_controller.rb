class RostersController < ApplicationController
  before_action :set_team_with_roster, only: :show

  def show
  end

  private
    def set_team_with_roster
      @week = (params[:week] || GameWeek.current).to_i
      
      @team = Team.where(id: params[:id]).
        joins(:roster_spots).
        where("roster_spots.week" => @week).
        includes(roster_spots: {player: [:projections, :points]}).
        # references(:roster_spots, :player, :projections, :points).
        where("player_point_totals.week" => @week).
        first
    end
end