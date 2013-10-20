class ArmchairAnalysis::Offense < ActiveRecord::Base
  def cache_key
    [super, uid].join
  end

  belongs_to :player, {
    primary_key: :armchair_analysis_id,
    foreign_key: :player,
    class_name: '::Player'
  }

  def cached_player
    @cached_player ||= Scout.cache.fetch([Player.name, 'player', self[:player]]) { player }
  end

  # N.B. It's not named just "game" because there is already a 'game' column on this table.
  belongs_to :game_in_season, {
    primary_key: :gid,
    foreign_key: :gid,
    class_name: 'ArmchairAnalysis::Game'
  }

  # TODO Fix
  # has_one :redzone_opportunity, {
  #   through: :game,
  #   foreign_key: :player,
  #   primary_key: :player
  # }

  has_one :redzone_opportunity, ->(offense) { where(gid: offense.gid) }, {
    primary_key: :player,
    foreign_key: :player
  }

  def cached_redzone_opportunity
    @cached_redzone_opportunity ||= Scout.cache.fetch(['redzone_opportunity', uid]) { redzone_opportunity }
  end

  has_one :team_performance, {
    foreign_key: :gid,
    primary_key: :gid,
    class_name: 'ArmchairAnalysis::Team'
  }

  has_many :field_goal_attempts, ->(offense) { where(fgxp: 'FG').includes(:core) }, {
    foreign_key: :fkicker,
    primary_key: :player,
  }

  def league_average(stat)
    ArmchairAnalysis::Offense.joins(:player).
      references(:player).
      where("players.position" => player.position, game: game).
      average(stat).to_i
  end

  def league_median(stat)
    base_query = ArmchairAnalysis::Offense.joins(:player).
      references(:player).
      where("players.position" => player.position, game: game)

    base_query.order(stat => :asc).
      offset(base_query.count / 2).
      limit(1).take.send(stat)
  end
end