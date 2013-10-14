class Injury < ActiveRecord::Base
  belongs_to :player, {
    :primary_key => :fantasy_football_nerd_id,
    :foreign_key => :fantasy_football_nerd_id,
    inverse_of: :injuries
  }, touch: true

  def cached_player
    Rails.cache.fetch([Player.name, 'fantasy_football_nerd_id', fantasy_football_nerd_id]) { player }
  end

  scope :for_current_week, -> {
    where(week: GameWeek.current.week)
  }

  scope :game_statuses, -> {
    for_current_week.
      where.not(game_status: '').
      select(:game_status).
      distinct.map(&:game_status).sort
  }

  scope :practice_statuses, -> {
    for_current_week.
      where.not(practice_status: '').
      select(:practice_status).
      distinct.map(&:practice_status).sort
  }

  scope :injuries, -> {
    for_current_week.
      where.not(injury: '').
      select(:injury).
      distinct.map(&:injury).sort
  }

  class << self
    include Scout::ImportLogging
    # TODO Implement something like 'include Scout::PayloadConversion'

    def from_payload(payload)
      new(attributes_from_payload(payload))
    end

    def attributes_from_payload(payload)
      {
        fantasy_football_nerd_id: payload.id,
        week:                     payload.injury.week,
        injury:                   payload.injury.injury_desc,
        practice_status:          payload.injury.practice_status_desc,
        game_status:              payload.injury.game_status_desc,
        last_update:              payload.injury.last_update
      }
    end

    # TODO Maybe create an importer object that hides away most logging
    # According to FFN: The data changes daily at 12:00 Eastern and 5:00 PM Eastern.
    # Policy: Update old one for this week
    def import(week = GameWeek.current.week)
      import_log "Started week #{week} import at #{Time.now}"

      existing_injuries  = where(week: week).order(last_update: :desc).load

      import_log "existing_injuries for week #{week}: #{existing_injuries.size}"

      if most_recent_existing_injury = existing_injuries.first
        import_log "most_recent_existing_injury: #{most_recent_existing_injury.last_update}"
      end

      injuries_this_week = FFNerd.injuries(week)

      import_log "injuries_this_week: #{injuries_this_week.size}"
      import_log "newest new injury: #{injuries_this_week.map(&:injury).sort_by(&:last_update).last.last_update}"

      new_injuries_this_week = injuries_this_week.select do |injury|
        if most_recent_existing_injury
          injury.injury.last_update >= most_recent_existing_injury.last_update
        else
          Date.today
        end
      end
      import_log "new_injuries_this_week: #{new_injuries_this_week.size}"

      if new_injuries_this_week.empty?
        import_log "new_injuries_to_save: #{new_injuries_to_save.size}"
      else
        lookup = existing_injuries.inject({}) do |id_to_injury, injury|
          id_to_injury[injury.fantasy_football_nerd_id] = injury
          id_to_injury
        end

        new_injuries_to_save = new_injuries_this_week.map do |new_injury|
          if existing_injury = lookup[new_injury.id]
            existing_injury.attributes = Injury.attributes_from_payload(new_injury)
            if existing_injury.changed?
              existing_injury
            else
              nil
            end
          else
            Injury.from_payload(new_injury)
          end
        end.compact

        import_log "new_injuries_to_save: #{new_injuries_to_save.size}"
        new_injuries_to_save.each(&:save)
      end

      import_log "Done at #{Time.now}"
    rescue Exception => e
      import_log "Exception! #{e.message}: #{e.backtrace.join("\n")}"
    end
  end
end
