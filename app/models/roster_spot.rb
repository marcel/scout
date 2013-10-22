class RosterSpot < ActiveRecord::Base
  include Comparable

  belongs_to :player, {
    foreign_key: :yahoo_player_key,
    primary_key: :yahoo_key,
    inverse_of: :roster_spots
  }, touch: true

  belongs_to :team, {
    foreign_key: :yahoo_team_key,
    primary_key: :yahoo_key,
    inverse_of: :roster_spots
  }

  STARTING_POSITIONS = Set.new(%w[QB WR RB TE W/R/T K DEF])

  def starter?
    STARTING_POSITIONS.include?(position)
  end

  def bench?
    !starter?
  end

  def swapable_spot?(other_spot)
    p "#{position} or #{player.position} can play #{other_spot.position} or #{other_spot.player.position}: #{(eligible_positions.include?(other_spot.position) || eligible_positions.include?(other_spot.player.position))}"
    p "#{other_spot.position} or #{other_spot.player.position} can play #{position} or #{player.position}: #{(other_spot.eligible_positions.include?(player.position) || other_spot.eligible_positions.include?(position))}"
    r = other_spot != self &&
    (eligible_positions.include?(other_spot.position) || eligible_positions.include?(other_spot.player.position)) &&
    (other_spot.eligible_positions.include?(player.position) || other_spot.eligible_positions.include?(position))
    p "swappable? #{r}"
    r
  end

  POSITION_ORDERING = {
    'QB'    => 1,
    'WR'    => 2,
    'RB'    => 3,
    'TE'    => 4,
    'W/R/T' => 5,
    'K'     => 6,
    'DEF'   => 7,
    'BN'    => 8
  }

  FLEXIBLE_POSITIONS = Set.new(%w[WR RB TE])

  # ELIGIBLE_POSITIONS = {}
  # ELIGIBLE_POSITIONS.default_proc = ->(hash, position) do
  #   p "#{hash.keys} -> #{position}"
  #   eligible_positions = if FLEXIBLE_POSITIONS.include?(position)
  #     [position, 'W/R/T', 'BN']
  #   else
  #     [position, 'BN']
  #   end
  #
  #   hash[position] = Set.new(eligible_positions.uniq)
  # end

  def eligible_positions
    eligible = if FLEXIBLE_POSITIONS.include?(position)
      [player.position, position, 'W/R/T', 'BN']
    else
      [player.position, position, 'BN']
    end
    #ELIGIBLE_POSITIONS[position]
    r = Set.new(eligible)
    p "eligible positions for #{position}: #{r.to_a}"
    r
  end

  POSITION_ORDERING.default = 0.1/0

  def <=>(other_roster_spot)
    POSITION_ORDERING[position] <=> POSITION_ORDERING[other_roster_spot.position]
  end


  class << self
    attr_accessor :optimal_roster_cache

    include Scout::Importing

    class Swap
      attr_reader :spot_1, :spot_2
      def initialize(spot_1, spot_2)
        @spot_1 = spot_1
        @spot_2 = spot_2
      end
    end


    # TODO This should probably exist on as-of-yet non-existant Roster as should much in here like position ordering
    def optimal_roster(spots)
      # TODO Get rid of this janky ad-hoc caching when optimal_roster is refactored
      mk_key = ->(s) { s.first.week.to_s + s.map(&:id).join(':') }
      key = mk_key.(spots)
      return optimal_roster_cache[key] if optimal_roster_cache.has_key?(key)

      res = spots.map do |spot|
        p "#{spot.position} eligible_positions: #{spot.eligible_positions.to_a}"
        other_positions = spot.eligible_positions - [spot.position]
        p "other_positions: #{other_positions}"
        swaps_to_try = other_positions.map do |position|
          swaps_to_consider = (spots - [spot]).select do |eligible_spot|
            other_positions.include?(eligible_spot.position) && eligible_spot.swapable_spot?(spot)
          end.compact
          p "swaps_to_consider: #{swaps_to_consider}"

          swaps_to_consider.map do |swapable_spot|
            p "spot: #{spot.attributes}"
            p "swappable spot: #{swapable_spot.attributes}"
            new_spot_after_swapping        = RosterSpot.new(swapable_spot.attributes)
            new_spot_after_swapping.player = spot.player
            p "new_spot_after_swapping: #{new_spot_after_swapping.player}"

            original_spot_after_swapping        = RosterSpot.new(spot.attributes)
            original_spot_after_swapping.player = swapable_spot.player
            p "original_spot_after_swapping: #{original_spot_after_swapping.player}"
            Swap.new(original_spot_after_swapping, new_spot_after_swapping)
          end
        end.flatten

        p "swaps_to_try: #{swaps_to_try}"

        finger_print = ->(candidate_lineup) {
          v = candidate_lineup.sort.map {|s| [s.position, s.yahoo_player_key].join(':')}.join
          p v
          p [v].pack('m0')
          v
        }

        compute_points = ->(candidate_lineup) {
          v = candidate_lineup.select(&:starter?).map(&:player).map {|p| p.points_on_week(GameWeek.current.week)}.map(&:total).sum
          p v
          v
        }

        original_fp = finger_print.(spots)
        permutations = {original_fp => compute_points.(spots)}

        swaps_to_try.each do |swap|
          updated = spots.dup.delete_if do |s|
            b = [swap.spot_1.yahoo_player_key, swap.spot_2.yahoo_player_key].include?(s.yahoo_player_key)
            p "boolean: #{b}"
            b
          end
          updated.concat([swap.spot_1, swap.spot_2])
          fp = finger_print.(updated)

          permutations[fp] ||= compute_points.(updated)
          p "number of permutation keys: #{permutations.keys.size}"
          p permutations
        end

        p "max is #{permutations.values.max}"
        p "min is #{permutations.values.min}"
        [permutations.values.max, permutations.values.min]
      end.flatten

      optimal_roster_cache[key] = res
      res
    end

    def from_payload(team_key, payload)
      new(attributes_from_payload(team_key, payload))
    end

    def attributes_from_payload(team_key, payload)
      playing_status = payload.status if payload.status?
      {
        yahoo_team_key:   team_key,
        yahoo_player_key: payload.player_key,
        week:             payload.selected_position.week,
        position:         payload.selected_position.position,
        playing_status:   playing_status
      }
    end

    # Policy: Create new one for this week
    def import(week = GameWeek.current.week)
      importing(week) do
        existing_roster_spots_for_week = RosterSpot.where(week: week, active: true).
          includes(:team).
          order(updated_at: :desc).load

        import_log "existing_roster_spots_for_week #{week}: #{existing_roster_spots_for_week.size}"

        client   = Scout::Client.new
        resource = Scout::Resource.league / 'teams' / 'roster' + {:type => 'week', :week => week} + 'players' + 'ownership'

        updated_roster_spots_for_week = client.request(resource) do |results|
          results.teams.map do |team|
            Scout::Payload::Team.new(team)
          end
        end

        lookup = existing_roster_spots_for_week.inject({}) do |team_to_player_keys_to_roster_spot, roster_spot|
          team_to_player_keys_to_roster_spot[roster_spot.yahoo_team_key] ||= {}
          team_to_player_keys_to_roster_spot[roster_spot.yahoo_team_key][roster_spot.yahoo_player_key] ||= []
          team_to_player_keys_to_roster_spot[roster_spot.yahoo_team_key][roster_spot.yahoo_player_key] << roster_spot
          team_to_player_keys_to_roster_spot
        end

        new_roster_spots     = 0
        updated_roster_spots = 0
        roster_spots_to_save = updated_roster_spots_for_week.map do |roster_spot|
          team_key = roster_spot.team_key
          roster_spot.roster.players.player.map do |payload|
            player = Scout::Payload::Player.new(payload)

            if lookup.has_key?(team_key) && (existing_roster_spots = lookup[team_key][player.player_key])
              lookup[team_key].delete(player.player_key)
              sorted = existing_roster_spots.sort_by(&:updated_at)
              newest_existing_roster_spot = sorted.pop
              if sorted.any?
                rest = existing_roster_spots
                lookup[team_key][player.player_key] = sorted
              end
              attributes_for_current_roster_spot = RosterSpot.attributes_from_payload(team_key, player)
              newest_existing_roster_spot.attributes = attributes_for_current_roster_spot
              if newest_existing_roster_spot.changed?
                updated_roster_spots += 1
                RosterSpot.new(attributes_for_current_roster_spot)
              else
                nil
              end
            else
              new_roster_spots += 1
              RosterSpot.from_payload(team_key, player)
            end
          end
        end.flatten.compact
        existing_roster_spots_that_became_inactive = lookup.values.map(&:values).flatten
        existing_roster_spots_that_became_inactive.each do |inactive_roster_spot|
          inactive_roster_spot.active = false
        end

        import_log "existing_roster_spots_that_became_inactive: #{existing_roster_spots_that_became_inactive.size}"
        import_log "roster_spots_to_save: #{roster_spots_to_save.size}"
        import_log "new_roster_spots: #{new_roster_spots}"
        import_log "updated_roster_spots: #{updated_roster_spots}"
        roster_spots_to_save.each(&:save)
        existing_roster_spots_that_became_inactive.each(&:save)
      end
    end
  end
  self.optimal_roster_cache ||= {}
end
