class Player < ActiveRecord::Base
  has_many :roster_changes, { # TODO Implement or not
    :primary_key => :yahoo_key,
    :foreign_key => :yahoo_player_key
  }
  has_many :roster_spots, { # TODO Implement or not
    primary_key: :yahoo_key,
    foreign_key: :yahoo_player_key,
    inverse_of: :player
  }

  belongs_to :owner, {
    foreign_key: :owner_key,
    primary_key: :yahoo_key,
    class_name: 'Team',
    inverse_of: :players
  }, touch: true

  def cached_owner
    @cached_owner ||= Scout.cache.fetch(['Team', owner_key, cache_key]) { owner }
  end

  has_many :injuries, {
    primary_key: :fantasy_football_nerd_id,
    foreign_key: :fantasy_football_nerd_id,
    inverse_of: :player
  }

  has_many :field_goal_attempts, ->{ where(fgxp: 'FG')}, {
    foreign_key: :fkicker,
    primary_key: :armchair_analysis_id,
    class_name: 'ArmchairAnalysis::FieldGoalExtraPoint'
  }

  INJURED_PLAYING_STATUSES = Set.new(%w[IR O])

  def injured?
    INJURED_PLAYING_STATUSES.include?(playing_status)
  end

  def defense?
    position == 'DEF'
  end

  def intercepted
    ArmchairAnalysis::Interception.
      joins(:play).
      where("armchair_analysis_plays.off = ?", armchair_analysis_team_name)
  end

  def cached_intercepted
    @cached_intercepted ||= Scout.cache.fetch(['intercepted', armchair_analysis_team_name], expires_in: 1.day) {
      intercepted.to_a
    }
  end

  def interceptions
    ArmchairAnalysis::Interception.
      joins(:play).
      where("armchair_analysis_plays.def = ?", armchair_analysis_team_name)
  end

  def cached_interceptions
    @cached_interceptions ||= Scout.cache.fetch(['interceptions', armchair_analysis_team_name], expires_in: 1.day) {
      interceptions.to_a
    }
  end

  def recovered_fumbles
     ArmchairAnalysis::Defense.where(team: armchair_analysis_team_name).where("frcv != 0")
  end

  def cached_recovered_fumbles
    @cached_recovered_fumbles ||= Scout.cache.fetch(['recovered-fumbles', armchair_analysis_team_name], expires_in: 1.day) {
      recovered_fumbles.to_a
    }
  end

  def total_turnovers
    cached_interceptions.size + cached_recovered_fumbles.map(&:frcv).sum
  end

  def probability_z(other_player)
    umann_whitney(other_player).probability_z
  end

  def umann_whitney(other_player)
    Statsample::Test::UMannWhitney.new(point_vector, other_player.point_vector)
  end

  def point_vector
    cached_points.map(&:total).to_scale
  end

  has_many :projections, {
    primary_key: :fantasy_football_nerd_id,
    foreign_key: :fantasy_football_nerd_id,
    inverse_of: :player
  } # do
  #     def on_week(week)
  #       self.select {|p| p.week == week } # N.B. Explicit self causes the loaded collection to be used rather than querying
  #     end
  #   end

  def cached_projections
    @cached_projections ||= Scout.cache.fetch(['projections', cache_key]) {
      projections.to_a.select do |projection|
        !cached_bye_weeks.include?(projection.week)
      end
    }
  end

  def defensive_performances

  end

  has_many :points, {
    :primary_key => :yahoo_key,
    :foreign_key => :yahoo_player_key,
    :class_name  => 'PlayerPointTotal',
    inverse_of: :player
  } # do
   #    def on_week(week)
   #      self.select do |point_total|
   #        point_total.week == week
   #      end.sort_by(&:updated_at).last
   #    end
   #  end
  def cached_points
    @cached_points ||= Scout.cache.fetch(['points', cache_key]) {
      points.to_a.select do |point|
        !cached_bye_weeks.include?(point.week)
      end
    }
  end

  def weekly_average_points
    (cached_points.map(&:total).sum.to_f / cached_points.size).round(1)
  end

  def weekly_average_points_excluding_max
    ((cached_points.map(&:total).sum.to_f - cached_points.max_by(&:total).total) / (cached_points.size - 1)).round(1)
  end

  def std_dev_of_points
    cached_points.map(&:total).standard_deviation.round(1)
  end

  def best_point_performance
    cached_points.max_by(&:total).total
  end

  def worst_point_performance
    cached_points.min_by(&:total).total
  end

  has_many :stats, {
    primary_key: :yahoo_key,
    foreign_key: :yahoo_player_key,
    class_name: 'PlayerStatValue',
    inverse_of: :player
  }

  has_many :watches, inverse_of: :player

  def cached_watches
    @cached_watches ||= Scout.cache.fetch(['watches', cache_key]) { watches.to_a }
  end

  has_many :expert_ranks, {
    primary_key: :yahoo_key,
    foreign_key: :yahoo_player_key,
    inverse_of: :player
  }

  def cached_expert_ranks
    @cached_expert_ranks ||= Scout.cache.fetch(['expert_ranks', cache_key]) { expert_ranks.to_a }
  end

  has_many :teammates, {
    class_name: "Player",
    foreign_key: "team_abbr",
    primary_key: "team_abbr"
  }

  has_many :home_games, {
    primary_key: :team_abbr,
    foreign_key: :home_team,
    class_name: 'Game'
  } do
    def on_week(week)
      self.detect do |game|
        game.week == week
      end
    end
  end

  def cached_home_games
    @cached_home_games ||= Scout.cache.fetch(['home_games', cache_key]) { home_games.to_a }
  end

  def cached_away_games
    @cached_away_games ||= Scout.cache.fetch(['away_games', cache_key]) { away_games.to_a }
  end

  # Figure out if there is a better way to get this
  def bye_weeks
    Set.new(((1..17).to_a - (cached_home_games.map(&:week) + cached_away_games.map(&:week))))
  end

  def cached_bye_weeks
    @cached_bye_weeks ||= Scout.cache.fetch(['bye_weeks', team_abbr]) { bye_weeks }
  end

  belongs_to :team, ->{ where(position: 'DEF') }, {
    primary_key: :team_abbr,
    foreign_key: :team_abbr,
    class_name: '::Player'
  }

  has_many :carries, {
    primary_key: :armchair_analysis_id,
    foreign_key: :bc,
    class_name: 'ArmchairAnalysis::Rush'
  }

  has_many :players_on_team, {
    primary_key: :team_abbr,
    foreign_key: :team_abbr,
    class_name: '::Player'
  }

  has_many :plays_by_team, {
    class_name: 'ArmchairAnalysis::Play'
    }, through: :games

  scope :redzone_carries, ->(within = 5) {
    joins(:play).where("armchair_analysis_plays.yfog >= ?", (100 - within))
  }

  # has_many :redzone_carries, ->(within = 5) {
  #   # joins(:play).where("armchair_analysis_plays.yfog >= ?", (100 - within))
  #   merge(Player.redzone_carries(within))
  # }, {
  #   primary_key: :armchair_analysis_id,
  #   foreign_key: :bc,
  #   class_name: 'ArmchairAnalysis::Rush'
  # }


  module QuarterBack
    def self.included(model)
      model.has_many :passes, {
        primary_key: :armchair_analysis_id,
        foreign_key: :psr,
        class_name: 'ArmchairAnalysis::Pass'
      }
    end

    # Formula: http://www.nfl.com/help/quarterbackratingformula
    def passer_rating_on_week(week)
      @passer_rating_on_week ||= {}

      @passer_rating_on_week[week] ||= Scout.cache.fetch(['passer-rating', week, cache_key]) {
        enforce_bounds = ->(stat) { [0.0, [stat, 2.375].min].max }

        attempts    = passes.merge(Play.on_week(week)).select("armchair_analysis_passes.pid")
        completions = attempts.completions

        yards                 = completions.pluck(:yds).sum
        touchdowns            = completions.scoring_plays.count
        interceptions         = attempts.interceptions.count
        number_of_attempts    = attempts.count.to_f
        number_of_completions = completions.count.to_f

        completion_stat        = (number_of_completions.percent_of(number_of_attempts) - 30) * 0.05
        yards_per_attempt_stat = ((yards / number_of_attempts) - 3.0) * 0.25
        touchdown_stat         = touchdowns.percent_of(number_of_attempts) * 0.2
        interception_stat      = 2.375 - (interceptions.percent_of(number_of_attempts) * 0.25)

        (
          enforce_bounds[completion_stat]        +
          enforce_bounds[yards_per_attempt_stat] +
          enforce_bounds[touchdown_stat]         +
          enforce_bounds[interception_stat]
        ) * 100.0 / 6
      }
    end

    def passer_rating_per_week
      @passer_rating_per_week ||= begin
        weeks = passes.joins(:game).
          group("armchair_analysis_games.wk").
          select("armchair_analysis_games.wk as week").
          map(&:week)

        weeks.inject({}) do |ratings, week|
          ratings[week] = passer_rating_on_week(week)
          ratings
        end
      end
    end

    def highest_passer_rating
      passer_rating_per_week.values.max
    end

    def lowest_passer_rating
      passer_rating_per_week.values.min
    end

    def average_passer_rating
      passer_rating_per_week.values.average
    end

    def pass_count_per_week
      passes.joins(:game).group("armchair_analysis_games.wk").count
    end

    def average_pass_attempts_per_week
      pass_count_per_week.values.average
    end

    # TODO Fix this. It only returns weeks that had an interception, since it doesn't join weeks with none.
    def interceptions_per_game
      interceptions.joins(:game).group("armchair_analysis_games.wk").count
    end

    def average_interceptions_per_game
      interceptions_per_game.values.average
    end

    def most_interceptions_in_a_game
      interceptions_per_game.values.max
    end

    def passer_rating_score_on_week(week)
      perfect_score = 158.3
      passer_rating_on_week(week).percent_of(perfect_score).round(2)
    end

    def redzone_passing_touchdowns(within = 20)
      passes.completions.in_redzone(within).scoring_plays
    end
  end
  include QuarterBack

  module RunningBack
    # X  Carries
    # X  Carries as % of team's total
    # X  Yards Per Carry
    # X  Rushing Touchdowns
    # Touchdowns as % of teams rushing total
    # Carries within the TD zone
    # Carries within the TD Zone as % of teams total
    # Targets
    # Receiving TD's

    def average_yards_per_carry
      carries.average(:yds)
    end

    def percent_successful_carries
      carries.successful_plays.count.percent_of(carries.count)
    end

    def longest_carry
      carries.select("MAX(yds) as max").first.try(:max)
    end

    def carry_count_by_week
      carries.joins(:game).group("armchair_analysis_games.wk").count
    end

    def most_carries_in_a_game
      carry_count_by_week.values.max
    end

    def fewest_carries_in_a_game
      carry_count_by_week.values.min
    end

    def average_carries_in_a_game
      carry_count_by_week.values.average
    end

    def rushing_touchdowns
      carries.joins(:scoring_play)
    end

    def rushing_touchdowns_by_team
      carries_by_team.scoring_plays.count
    end

    def redzone_carries_within_the_5
      carries.in_redzone(5)
    end

    def redzone_carries_within_the_3
      carries.in_redzone(3)
    end

    def redzone_carries_within_the_1
      carries.in_redzone(1)
    end

    def percent_of_redzone_carries_on_team(within = 5)
      carries.in_redzone(within).count.percent_of(carries_by_team.in_redzone(within).count)
    end

    def carries_by_team
      @carries_by_team ||= ArmchairAnalysis::Rush.by_team(team_abbr)
    end

    def percent_of_carries_on_team
      carries.count.percent_of(carries_by_team.count)
    end

    def percent_of_scoring_carries_on_team
      carries.scoring_plays.count.percent_of(carries_by_team.scoring_plays.count)
    end

    def fumbles
      carries.joins(:fumble)
    end
  end
  include RunningBack

  module WideReceiver
    def self.included(model)
      model.has_many :targets, {
        primary_key: :armchair_analysis_id,
        foreign_key: :trg,
        class_name: 'ArmchairAnalysis::Pass'
      }
    end

    def receptions
      targets.receptions
    end

    def percent_passes_caught
      receptions.count.percent_of(targets.count)
    end

    def average_yards_per_reception
      receptions.average(:yds).to_f
    end

    def target_count_by_week
      targets.joins(:game).group("armchair_analysis_games.wk").count
    end

    def reception_count_by_week
      receptions.joins(:game).group("armchair_analysis_games.wk").count
    end

    def most_targets_in_a_game
      target_count_by_week.values.max
    end

    def fewest_targets_in_a_game
      target_count_by_week.values.min
    end

    def average_targets_in_a_game
      target_count_by_week.values.average
    end

    def percent_successful_receptions
      receptions.successful_plays.count.percent_of(receptions.count)
    end

    def longest_reception
      receptions.select("MAX(yds) as max").first.try(:max)
    end

    def receiving_touchdowns
      receptions.scoring_plays
    end

    def targets_by_team
      @targets_by_team ||= ArmchairAnalysis::Pass.by_team(team_abbr)
    end

    def receiving_touchdowns_by_team
      targets_by_team.completions.scoring_plays.count
    end

    def redzone_targets_within_the_10
      targets.in_redzone(10)
    end

    def redzone_targets_within_the_5
      targets.in_redzone(5)
    end

    def percent_of_redzone_targets_on_team(within = 10)
      targets.in_redzone(within).count.percent_of(targets_by_team.in_redzone(within).count)
    end

    def percent_of_targets_on_team
      targets.count.percent_of(targets_by_team.count)
    end

    def percent_of_scoring_receptions_on_team
      receptions.scoring_plays.count.percent_of(targets_by_team.receptions.scoring_plays.count)
    end
  end
  include WideReceiver

  module PlayerAsTeam
    def self.included(model)
      model.has_many :drives, {
        primary_key: :armchair_analysis_team_name,
        foreign_key: :tname,
        class_name: "ArmchairAnalysis::Drive"
      }
    end
  end
  include PlayerAsTeam

  module Kicker
    def self.included(model)
      model.has_many :field_goal_attempts, -> { where(fgxp: 'FG') }, {
        primary_key: :armchair_analysis_id,
        foreign_key: :fkicker,
        class_name: "ArmchairAnalysis::FieldGoalExtraPoint"
      }
    end

    def percent_field_goals_made
      field_goal_attempts.made.count.percent_of(field_goal_attempts.count)
    end

    def field_goal_attempts_by_week
      field_goal_attempts.joins(:game).group("armchair_analysis_games.wk").count
    end

    def most_field_goal_attempts_in_a_game
      field_goal_attempts_by_week.values.max
    end

    def fewest_field_goal_attempts_in_a_game
      field_goal_attempts_by_week.values.min
    end

    def average_field_goal_attempts_in_a_game
      field_goal_attempts_by_week.values.average
    end
  end
  include Kicker

  def games_played
    # TODO Implement
  end

  has_many :away_games, {
    primary_key: :team_abbr,
    foreign_key: :away_team,
    class_name: 'Game'
  } do
    def on_week(week)
      self.detect do |game|
        game.week == week
      end
    end
  end

  has_many :game_performances_for_team, {
    primary_key: :armchair_analysis_team_name,
    foreign_key: :tname,
    class_name: 'ArmchairAnalysis::Team'
  } # do
   #    def by_opponents
   #      ArmchairAnalysis::Team.where(gid: self.map(&:gid)).
   #        includes(:game).
   #        where.not(tname: self.first.tname).
   #        sort_by {|t| t.game.wk }
   #    end
   #  end

  def cached_game_performances_for_team
    @cached_game_performances_for_team ||= Scout.cache.fetch(['game_performances_for_team', armchair_analysis_team_name], expires_in: 1.day) {
      game_performances_for_team.to_a
    }
  end

  def game_performances_by_opponents
    game_performances = cached_game_performances_for_team

    gids = game_performances.map(&:gid)
    ArmchairAnalysis::Team.where(gid: gids).
      where.not(tname: game_performances.first.tname).
      sort_by {|t| t.game.wk }
  end

  def cached_game_performances_by_opponents
    @cached_game_performances_by_opponents ||= Scout.cache.fetch(['game_performances_by_opponents', armchair_analysis_team_name], expires_in: 1.day) {
      game_performances_by_opponents.to_a
    }
  end

  scope :defense, ->{
    where(position: 'DEF')
  }

  scope :players_with_no_team, ->{
    where(armchair_analysis_team_id: nil).load
  }

  has_many :offensive_performances, {
    foreign_key: :player,
    primary_key: :armchair_analysis_id,
    class_name: 'ArmchairAnalysis::Offense'
  } do
    def on_week(week)
      self.detect do |offensive_performance|
        offensive_performance.game == week
      end
    end

    def has_targets?
      !self.map(&:trg).sum.zero?
    end

    def has_rush_attempts?
      !self.map(&:ra).sum.zero?
    end

    def has_pass_attempts?
      !self.map(&:pa).sum.zero?
    end
  end

  def offensive_output
    performances = game_performances_for_team
    percent_3rd_down_conversions = (
      (performances.map(&:s3c).sum + performances.map(&:l3c).sum).to_f /
      (performances.map(&:s3a).sum + performances.map(&:l3a).sum)
    ) * 100

    {
      points: performances.map(&:pts).sum,
      max_points: performances.map(&:pts).max,
      avg_points: performances.map(&:pts).sum / performances.size,
      sacked: performances.map(&:sk).sum,
      intercepted: performances.map(&:int).sum,
      fumbled: performances.map(&:fum).sum,
      punts: performances.map(&:pu).sum,
      penalty_yardage: performances.map(&:pen).sum,
      drives_in_redzone: performances.map(&:rza).sum,
      big_rush_yardage: performances.map(&:bry).sum,
      big_pass_yardage: performances.map(&:bpy).sum,
      medium_completions: performances.map(&:mpc).sum,
      long_completions: performances.map(&:lpc).sum,
      punts_inside_20: performances.map(&:i20).sum,
      percent_3rd_down_conversions: percent_3rd_down_conversions.round(1),
      dumb_penalties: performances.map(&:dum).sum
    }
  end

  DEFAUL_OFFENSIVE_OUTPUT_BOOSTS = {

  }

  def offensive_output_score(boosts = DEFAUL_OFFENSIVE_OUTPUT_BOOSTS)
    output = offensive_output
    rest_of_league = Player.defense.where.not(team_abbr: team_abbr).includes(:game_performances_for_team).load
    output_from_league = rest_of_league.map(&:offensive_output)

    output.keys.inject({}) do |score, key|
      # if boosts.has_key?(key)
        # boost = boosts[key]
        league_max = output_from_league.max_by {|o| o[key] }[key]
        team_value = output[key]
        percentage_in_league = league_max > team_value ? team_value.to_f / league_max * 100 : 100.0
        # score + (output[key] * boost)
        score[key] = [percentage_in_league.round(1), league_max, team_value]
        score
      # else
        # score + output[key]
      # end
    end
  end

  has_one :extended_bio, {
    foreign_key: :player,
    primary_key: :armchair_analysis_id,
    class_name: 'ArmchairAnalysis::Player'
  }

  has_many :redzone_opportunities, {
    primary_key: :armchair_analysis_id,
    foreign_key: :player,
    class_name: "ArmchairAnalysis::RedzoneOpportunity"
  }

  def cached_redzone_opportunities
    @cached_redzone_opportunities ||= Rais.cache.fetch(['redzone_opportunities', cache_key]) {
      redzone_opportunities.to_a
    }
  end

  # has_many :catches, -> {
  #   where(type: 'PASS', conv: 'Y')
  # }, {
  #   foreign_key: :trg,
  #   primary_key: :armchair_analysis_id,
  #   class_name: "ArmchairAnalysis::Conversion"
  # }

  def try_to_find_team(force = false)
    return nil if !armchair_analysis_team_name.nil? && !force

    team_name_to_match = team_abbr == 'Jax' ? 'JAC' : team_abbr.upcase

    if match = ArmchairAnalysis::Team.find_by(tname: team_name_to_match)
      self[:armchair_analysis_team_name] = team_name_to_match
      self
    else
      nil
    end
  end

  # has_many :games, ->(player) {
  #   where("games.home_team = ? OR games.away_team = ?", player.team_abbr, player.team_abbr)
  # }, primary_key: nil, foreign_key: nil

  def game_on_week(week)
    cached_home_games.find {|g| g.week == week } || cached_away_games.find {|g| g.week == week }
  end

  def opponent_on_week(week)
    if game = game_on_week(week)
      game.away_team == team_abbr ? game.home_team : game.away_team
    else
      nil
    end
  end

  def expert_rank_on_week(week)
    cached_expert_ranks.detect do |rank|
      rank.week == week
    end
  end

  def points_on_week(week)
    cached_points.select do |point_total|
      point_total.week == week
    end.sort_by(&:updated_at).last
  end

  def projection(week = GameWeek.current.week)
    # TODO Decide if defaulting to an empty projection is desirable, probably not
    cached_projections.select {|p| p.week == week }.sort_by(&:updated_at).last ||
      Projection.new(standard: 0.0, standard_high: 0.0, standard_low: 0.0)
  end

  def total_points
    cached_points.map(&:total).sum
  end

  TEAM_ABBR_LONG = %w[
    ari
    atl
    bal
    buf
    car
    chi
    cin
    cle
    dal
    den
    det
    gnb
    hou
    ind
    jac
    kan
    mia
    min
    nwe
    nor
    nyg
    nyj
    oak
    phi
    pit
    sdg
    sfo
    sea
    stl
    tam
    ten
    was
  ]

  SHORT_TO_LONG_TEAM_ABBR = TEAM_ABBR_LONG.inject({}) do |h, abbreviation|
    h[abbreviation[0,2]] = abbreviation
    h
  end

  SHORT_TO_LONG_TEAM_ABBR.update('kc' => 'kan', 'ne' => 'nwe', 'gb' => 'gnb', 'tb' => 'tam')

  def team_abbr_long
    if team_abbr.size == 2
      SHORT_TO_LONG_TEAM_ABBR[team_abbr.downcase]
    else
      team_abbr.downcase
    end
  end

  class PlayingStatus
    class << self
      attr_accessor :by_display_name, :by_abbreviation

      def lookup(display_name_or_abbreviation)
        by_display_name[display_name_or_abbreviation] ||
        by_abbreviation[display_name_or_abbreviation]
      end
    end

    attr_reader :display_name, :abbreviation

    def initialize(display_name, abbreviation)
      @display_name = display_name
      @abbreviation = abbreviation
    end

    def ===(object)
      /^(?:#{display_name}|#{abbreviation})$/ === object
    end

    silence_warnings {
      Questionable   = new('Questionable', 'Q')
      Out            = new('Out', 'O')
      InjuredReserve = new('Injured Reserve', 'IR')
      NotActive      = new('Not Active', 'NA')
      Probable       = new('Probable', 'P')

      All = [Questionable, Out, InjuredReserve, NotActive, Probable]
    }

    self.by_display_name = All.inject({}) do |h, ps|
      h[ps.display_name] = ps
      h
    end

    self.by_abbreviation = All.inject({}) do |h, ps|
      h[ps.abbreviation] = ps
      h
    end
  end

  class << self
    include Scout::Importing

    def from_payload(payload)
      new(attributes_from_payload(payload))
    end

    def attributes_from_payload(payload)
      status = payload.status if payload.status?
      owner_key, waiver_date, ownership_type = *ownership_status(payload)

      {
        yahoo_key:      payload.player_key,
        full_name:      payload.name.full,
        first_name:     payload.name.ascii_first,
        last_name:      payload.name.ascii_last,
        playing_status: status,
        team_full_name: payload.editorial_team_full_name,
        team_abbr:      payload.editorial_team_abbr,
        bye_week:       payload.bye_weeks.week,
        uniform_number: payload.uniform_number,
        position:       payload.display_position,
        position_type:  payload.position_type,
        headshot:       payload.headshot.url,
        owner_key:      owner_key,
        waiver_date:    waiver_date,
        ownership_type: ownership_type
      }
    end

    def ownership_status(payload)
      if payload.ownership?
        ownership_type = payload.ownership.ownership_type
        case ownership_type
        when 'team'
          [payload.ownership.owner_team_key, nil, ownership_type]
        when 'waivers'
          [nil, payload.ownership.waiver_date, ownership_type]
        when 'freeagents'
          [nil, nil, ownership_type]
        else
          import_log "Unrecognized ownership type for player #{payload.player_key}: `#{payload.ownership.ownership_type}`"
          [nil, nil, ownership_type]
        end
      else
        [nil, nil, nil]
      end
    end

    # Policy: Update old one
    def import(week = GameWeek.current.week)
      importing(week) do
        client = Scout::Client.new

        updated_players = client.players(:start => 0)
        import_log "updated_players: #{updated_players.size}"

        lookup = all.inject({}) do |id_to_player, player|
          id_to_player[player.yahoo_key] = player
          id_to_player
        end

        import_log "existing players: #{lookup.keys.size}"

        players_to_save = updated_players.map do |updated_player|
          if existing_player = lookup[updated_player.player_key]
            existing_player.attributes = Player.attributes_from_payload(updated_player)
            if existing_player.changed?
              existing_player
            else
              nil
            end
          else
            Player.from_payload(updated_player)
          end
        end.compact

        import_log "players_to_save: #{players_to_save.size}"
        players_to_save.each(&:save)
      end
    end
  end
end
