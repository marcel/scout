class ExpertRanksController < ApplicationController
  def index
    @week          = (params[:week] ||= GameWeek.current.week).to_i
    @position_type = (params[:position_type] ||= 'quarterback')


    query = ExpertRank.where(week: @week, position_type: @position_type).
      joins(:player).
      order(overall_rank: :asc)

    query = query.where("projections.standard > ?", params[:above]) if params[:above]
    query = query.where("projections.standard < ?", params[:below]) if params[:below]
    query = query.where("players.full_name LIKE ?", "%#{params[:name]}%") if params[:name]
    query = query.where("players.position" => params[:position].split(',')) if params[:position]
    query = query.where("players.team_abbr" => params[:team].split(',')) if params[:team]
    query = query.where("players.owner_key" => params[:owner]) if params[:owner]
    query = query.where("players.ownership_type" => params[:ownership_type].split(',')) if params[:ownership_type]

    @expert_ranks = query.load

    @actual_ranks = @expert_ranks.map(&:cached_player).sort_by do |player|
        -player.points_on_week(@week).total
    end.each_with_index.inject({}) do |actual_ranks, (player, index)|
      actual_ranks[player.id] = index + 1
      actual_ranks
    end

    if params[:rank_by] && params[:rank_by].to_s == 'points'
      @expert_ranks.sort_by! do |rank|
        @actual_ranks[rank.cached_player.id]
      end
    end

    render_fresh(@expert_ranks, :week)
  end
end
