class Stat < ActiveRecord::Base
  has_many :values, {
    class_name: 'PlayerStatValue',
    primary_key: :yahoo_stat_id,
    foreign_key: :yahoo_stat_id,
    inverse_of: :stat
  }
  
  class << self
    def by_stat_id
      @stats ||= begin
        all.inject({}) do |all, stat|
          all[stat.yahoo_stat_id] = stat
          all
        end
      end
    end

    def by_name(pattern)
      by_stat_id.values.select {|stat| stat.name =~ /#{pattern}/i }
    end

    def by_position_type
      @by_position ||= by_stat_id.values.group_by(&:position_type)
    end

    def from_payload(payload)
      new(
        :yahoo_stat_id => payload.stat_id,
        :name          => payload.name,
        :sort_order    => payload.sort_order,
        :position_type => position_type(payload),
        :display_name  => payload.display_name
      )
    end

    def position_type(payload)
      case payload.position_types.position_type
      when Array
        'ALL'
      when String
        payload.position_types.position_type
      else
        raise "Unrecognized position type: #{payload.position_types.inspect}"
      end
    end
  end

  def normalize_name
    name.gsub(' ', '_').downcase
  end
  
  class << self
    include Scout::Importing
    
    def import(week = GameWeek.current.week)
      importing(week) do
        client = Scout::Client.new

        stats = client.stats
        import_log "stats: #{stats.size}"

        stats.each do |stat|
          record = Stat.find_by(yahoo_stat_id: stat.stat_id) || from_payload(stat)
          record.save if record.new_record?
        end
      end
    end
  end
end
