require 'scout/importing'

class PlayerPointTotal < ActiveRecord::Base
  belongs_to :player, {
    :foreign_key => :yahoo_player_key,
    :primary_key => :yahoo_key,
    :class_name  => "Player",
    inverse_of: :points
  }, touch: true

  def cached_player
    Scout.cache.fetch(['Player', 'yahoo_player_key', yahoo_player_key]) { player }
  end

  class << self
    include Scout::Importing

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
      importing(week) do
        existing_player_points = where(week: week).load
        existing_player_stat_values = PlayerStatValue.where(week: week).load

        import_log "existing_player_points for week #{week}: #{existing_player_points.size}"
        import_log "existing_player_stat_values for week #{week}: #{existing_player_stat_values.size}"

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

        stat_values_lookup = existing_player_stat_values.inject({}) do |id_to_player_stat_values, stat_value|
          id_to_player_stat_values[stat_value.yahoo_player_key] ||= {}
          id_to_player_stat_values[stat_value.yahoo_player_key][stat_value.yahoo_stat_id] = stat_value
          id_to_player_stat_values
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
            player_point_total = PlayerPointTotal.from_payload(player)
            player_point_total.player = Player.where(yahoo_key: player_point_total.yahoo_player_key).take
            player_point_total
          end
        end.compact

        players_with_stats = latest_point_totals_this_week.select(&:player_stats?)

        new_stats = 0
        updated_stats = 0
        updated_player_stat_values_to_save = players_with_stats.map do |player|
          player_key = player.player_key
          player.player_stats.stats.stat.map do |stat|
            if existing_stats_for_player = stat_values_lookup[player_key]
              if existing_stat = existing_stats_for_player[stat.stat_id]
                existing_stat.value = stat.value.to_f
                if existing_stat.changed?
                  updated_stats += 1
                  existing_stat
                else
                  nil
                end
              else
                if stat.value.to_f > 0.0
                  new_stats += 1
                  PlayerStatValue.new(
                    player: player,
                    season: Date.today.year,
                    week: week,
                    yahoo_stat_id: stat.stat_id,
                    value: stat.value.to_f
                  )
                end
              end
            else
              if stat.value.to_f > 0.0
                new_stats += 1
                PlayerStatValue.new(
                  player: player,
                  season: Date.today.year,
                  week: week,
                  yahoo_stat_id: stat.stat_id,
                  value: stat.value.to_f
                )
              end
            end
          end
        end.flatten.compact

        import_log "updated_player_points_to_save: #{updated_player_points_to_save.size}"
        updated_player_points_to_save.each(&:save)
        import_log "updated_player_stat_values_to_save: #{updated_player_stat_values_to_save.size}"
        import_log "new_stats: #{new_stats}"
        import_log "updated_stats: #{updated_stats}"
        updated_player_stat_values_to_save.each(&:save)
      end
    end
  end
end
