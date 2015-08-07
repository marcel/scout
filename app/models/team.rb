class Team < ActiveRecord::Base
  has_many :rosters, {
    :primary_key => :yahoo_key,
    :foreign_key => :yahoo_team_key
  }
  
  has_many :players, {
    primary_key: :yahoo_key,
    foreign_key: :owner_key,
    inverse_of: :owner
  }
  
  has_many :roster_spots, {
    primary_key: :yahoo_key,
    foreign_key: :yahoo_team_key,
    inverse_of: :team
  }
  
  def projected_points(week)
    roster_spots.select do |spot| 
      spot.active? && !spot.bench?
    end.map(&:player).map do |player|
      player.projection(week)
    end.compact.map(&:standard).sum
  end
  
  def points(week)
    roster_spots.select do |spot|
      spot.active? && !spot.bench?
    end.map(&:player).map do |player|
      player.points_on_week(week)
    end.compact.map(&:total).sum
  end
  
  class << self
    include Scout::Importing
    
    def from_payload(payload)
      new(attributes_from_payload(payload))
    end
    
    def attributes_from_payload(payload)
      {
        yahoo_key:       payload.team_key,
        name:            payload.name,
        moves:           payload.number_of_moves,
        trades:          payload.number_of_trades,
        logo:            payload.team_logos.team_logo.url,
        # division_id:     payload.division_id,
        waiver_priority: payload.waiver_priority,
        faab_balance:    payload.faab_balance,
        manager:         payload.managers.manager.nickname   
      }
    end
    
    # Policy: Update old one
    def import(week = GameWeek.current.week)
      importing(week) do
        client = Scout::Client.new
      
        updated_teams = client.teams
      
        lookup = all.inject({}) do |id_to_team, team|
          id_to_team[team.yahoo_key] = team
          id_to_team
        end
        
        teams_to_save = updated_teams.map do |updated_team|
          if existing_team = lookup[updated_team.team_key]
            existing_team.attributes = Team.attributes_from_payload(updated_team)
            if existing_team.changed?
              existing_team
            else
              nil
            end
          else
            Team.from_payload(updated_team)
          end
        end.compact

        import_log "teams_to_save: #{teams_to_save.size}"
        teams_to_save.each(&:save)
      end
    end
  end
end
