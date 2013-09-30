class Stat < ActiveRecord::Base
  class << self
    def by_stat_id
      @stats ||= begin
        all.inject({}) do |all, stat|
          all[stat.stat_id] = stat
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
        :stat_id       => payload.stat_id,
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
end
