class Projection < ActiveRecord::Base
  belongs_to :player, {
    :primary_key => :fantasy_football_nerd_id,
    :foreign_key => :fantasy_football_nerd_id,
    inverse_of: :projections
  }, touch: true
  
  def cached_player
    Scout.cache.fetch([Player.name, 'fantasy_football_nerd_id', fantasy_football_nerd_id], expires_in: 20.minutes) { player }
  end

  scope :latest, -> {
    where(week: GameWeek.current.week).
    group(:fantasy_football_nerd_id).
    order("projections.rank" => :desc)
  }

  scope :on_week, ->(week) {
    where(week: week)
  }

  class << self
    include Scout::Importing

    def from_payload(payload)
      new(attributes_from_payload(payload))
    end

    def attributes_from_payload(payload)
      projection = payload.projection
      {
        fantasy_football_nerd_id: payload.id,
        week:                     projection.week,
        standard_high:            projection.standard_high,
        standard_low:             projection.standard_low,
        standard:                 projection.standard,
        ppr_high:                 projection.ppr_high,
        ppr_low:                  projection.ppr_low,
        ppr:                      projection.ppr,
        rank:                     payload.rank
      }
    end

    # According to FFN: The data changes daily at 12:00 Eastern.
    # Policy: Create new one for this week if changed
    def import(week = GameWeek.current.week)
      importing(week) do
        existing_projections = where(week: week).load

        import_log "existing_projections for week #{week}: #{existing_projections.size}"

        projections_for_this_week = FFNerd.projections(week)

        import_log "projections_for_this_week: #{projections_for_this_week.size}"

        lookup = existing_projections.inject({}) do |id_to_projection, projection|
          id_to_projection[projection.fantasy_football_nerd_id] = projection
          id_to_projection
        end

        new_records         = 0
        updated_projections = 0
        updated_ranks       = 0
        projections_to_save = projections_for_this_week.map do |projection|
          if existing_projection = lookup[projection.id]
            attributes_for_latest_projection = Projection.attributes_from_payload(projection)
            existing_projection.attributes = attributes_for_latest_projection
            if existing_projection.changed?
              if existing_projection.changed_attributes.keys == ["rank"]
                updated_ranks += 1
                existing_projection
              else
                updated_projections += 1
                Projection.new(attributes_for_latest_projection)
              end
            else
              nil
            end
          else
            new_records += 1
            Projection.from_payload(projection)
          end
        end.compact

        import_log "projections_to_save: #{projections_to_save.size}"
        import_log "new projections: #{new_records}"
        import_log "updated projections: #{updated_projections}"
        import_log "updated ranks: #{updated_ranks}"
        projections_to_save.each(&:save)
      end
    end
  end
end
