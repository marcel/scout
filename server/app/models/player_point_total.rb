class PlayerPointTotal < ActiveRecord::Base
  belongs_to :player, {
    :foreign_key => :yahoo_player_key, 
    :primary_key => :yahoo_key, 
    :class_name  => "Player"
  }
  
  class << self
    include Scout::ImportLogging
    def from_payload(payload)
      new(attributes_from_payload(payload))
    end
    
    def attributes_from_payload(payload)
      {
        yahoo_player_key: payload.player_key,
        week:             payload.player_points.week,
        total:            payload.player_points.total,
        season:           Date.today.year
      }
    end
    
    # Policy: Update old one for this week
    def import(week = GameWeek.current.week)
      import_log "Started week #{week} import at #{Time.now}"
      
      existing_player_points = where(week: week).load

      import_log "existing_player_points for week #{week}: #{existing_player_points.size}"

      client   = Scout::Client.new
      # TODO Encapsulate in client
      resource = Scout::Resource.league / 'players' + {start: 0} + 'stats' + {type: 'week', week: week}

      latest_point_totals_this_week = client.request(resource) do |result|
        result.players.map do |player| 
          Scout::Payload::Player.new(player)
        end
      end

      import_log "latest_point_totals_this_week: #{latest_point_totals_this_week.size}"
      
      lookup = existing_player_points.inject({}) do |id_to_player_point, point_total|
        id_to_player_point[point_total.yahoo_player_key] = point_total
        id_to_player_point
      end
      
      updated_player_points_to_save = latest_point_totals_this_week.map do |player|
        if existing_player_point = lookup[player.player_key]
          existing_player_point.attributes = PlayerPointTotal.attributes_from_payload(player)
          if existing_player_point.changed?
            existing_player_point
          else
            nil
          end
        else
          PlayerPointTotal.from_payload(player)
        end
      end.compact

      import_log "updated_player_points_to_save: #{updated_player_points_to_save.size}"
      updated_player_points_to_save.each(&:save)
      
      import_log "Done at #{Time.now}"
    rescue Exception => e
      import_log "Exception! #{e.message}: #{e.backtrace.join("\n")}"
    end
  end
end
