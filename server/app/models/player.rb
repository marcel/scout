class Player < ActiveRecord::Base
  has_many :roster_changes, { # TODO Implement or not
    :primary_key => :yahoo_key,
    :foreign_key => :yahoo_player_key
  }
  has_many :roster_spots, { # TODO Implement or not
    :primary_key => :yahoo_key,
    :foreign_key => :yahoo_player_key
  }

  belongs_to :owner, {
    foreign_key: :owner_key,
    primary_key: :yahoo_key,
    class_name: 'Team'
  }

  has_many :injuries, {
    :primary_key => :fantasy_football_nerd_id,
    :foreign_key => :fantasy_football_nerd_id
  }

  has_many :projections, {
    :primary_key => :fantasy_football_nerd_id,
    :foreign_key => :fantasy_football_nerd_id
  }

  has_many :points, {
    :primary_key => :yahoo_key,
    :foreign_key => :yahoo_player_key,
    :class_name  => 'PlayerPointTotal'
  }

  has_many :watches
  
  has_many :expert_ranks, {
    primary_key: :yahoo_key,
    foreign_key: :yahoo_player_key
  }
  
  def expert_rank_on_week(week)
    expert_ranks.detect do |rank|
      rank.week == week
    end
  end

  def points_on_week(week)
    # TODO Is there a way to not make this do N+1 queries?
    # points.where(week: week).first
    points.detect {|point_total| point_total.week == week }
  end

  def projection(week = GameWeek.current.week)
    # TODO Decide if defaulting to an empty projection is desirable, probably not
    projections.where(week: week).order(updated_at: :desc).first ||
      Projection.new(standard: 0.0, standard_high: 0.0, standard_low: 0.0)
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
    include Scout::ImportLogging

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
    def import
      import_log "Started import at #{Time.now}"

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

      import_log "Done at #{Time.now}"
    rescue Exception => e
      import_log "Exception! #{e.message}: #{e.backtrace.join("\n")}"
    end
  end
end
