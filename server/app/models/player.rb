class Player < ActiveRecord::Base
  has_many :roster_changes, {
    :primary_key => :yahoo_key,
    :foreign_key => :yahoo_player_key
  }
  has_many :roster_spots, {
    :primary_key => :yahoo_key,
    :foreign_key => :yahoo_player_key
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
        headshot:       payload.headshot.url
      }
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
