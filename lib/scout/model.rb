module Scout
  class Model
    class Data < Hash
      include Hashie::Extensions::MergeInitializer
      include Hashie::Extensions::MethodAccess

      def method_missing(method, *args, &block)
        if predicate = method.to_s[/(\w+)\?$/, 1]
          !self[predicate].nil?
        else
          super
        end
      end
    end

    class << self
      def contains(name, klass = name.to_s.capitalize, attribute = name)
        class_eval(<<-EVAL)
          def #{name}
            @#{name} ||= #{klass}.new(doc.at('#{attribute}'.to_s))
          end
        EVAL
      end

      def dump(model)
        [Zlib::Deflate.deflate(model.to_xml, Zlib::BEST_COMPRESSION)].pack('m0')
      end

      def load(bytes)
        new(Nokogiri::XML(Zlib::Inflate.inflate(bytes.unpack('m0').first)))
      end
    end

    attr_reader :doc, :data
    def initialize(doc)
      @doc = doc
      doc.instance_eval do
        def inspect; '...' end
      end
      @data = Data.new(XmlParser.parse(doc.to_xml))
    end

    # N.B. So pretty print doesn't display huge xml doc
    def instance_variables
      super - ["@doc"]
    end

    def method_missing(method, *args, &block)
      if data.respond_to?(method)
        data.send(method, *args, &block)
      elsif predicate = method.to_s[/(\w+)\?$/, 1]
        !self[predicate].nil?
      else
        super
      end
    end
  end

  class Manager < Model
  end

  class Stat < Model
  end

  class Game < Model
  end

  class League < Model
  end

  class Team < Model
    contains :manager

    def roster(week = nil)
      week_param = week ? ";week=#{week}" : ''
      @roster ||= Roster.new(client.get("team/#{team_key}/roster#{week_param}")['roster'], client)
    end
  end

  class Standings < Model
  end

  class MatchUp < Model
  end

  class Transaction < Model
    # N.B. Work around since the attribute is a built in method on Object
    def type
      data['type']
    end

    def players
      doc.css('player').map do |player|
        Player.new(player)
      end
    end
  end


  class Player < Model
    def offense?
      position_type == "O"
    end

    def defense?
      !offense?
    end
  end

  class Roster < Model
  end

  module Cache
    class Player < ActiveRecord::Base
      set_table_name :players
      has_many :roster_changes, {
        :primary_key => :yahoo_key,
        :foreign_key => :yahoo_player_key
      }
      has_many :rosters, {
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

      class << self
        def from_model(model)
          new(
            :yahoo_key  => model.player_key,
            :full_name  => model.name.full,
            :first_name => model.name.ascii_first,
            :last_name  => model.name.ascii_last,
            :xml        => Scout::Player.dump(model)
          )
        end
      end

      def to_model
        Scout::Player.load(xml)
      end
    end

    class Injury < ActiveRecord::Base
      set_table_name :injuries
      belongs_to :player, {
        :primary_key => :fantasy_football_nerd_id,
        :foreign_key => :fantasy_football_nerd_id
      }

      class << self
        def from_model(model)
          new(
            :fantasy_football_nerd_id => model.id,
            :week                     => model.injury.week,
            :injury                   => model.injury.injury_desc,
            :practice_status          => model.injury.practice_status_desc,
            :game_status              => model.injury.game_status_desc,
            :last_update              => model.injury.last_update
          )
        end
      end
    end

    class Projection < ActiveRecord::Base
      set_table_name :projections
      belongs_to :player, {
        :primary_key => :fantasy_football_nerd_id,
        :foreign_key => :fantasy_football_nerd_id
      }

      class << self
        def from_model(model)
          new(
            :fantasy_football_nerd_id => model.id,
            :week                     => model.projection.week,
            :standard_high            => model.projection.standard_high,
            :standard_low             => model.projection.standard_low,
            :standard                 => model.projection.standard,
            :ppr_high                 => model.projection.ppr_high,
            :ppr_low                  => model.projection.ppr_low,
            :ppr                      => model.projection.ppr,
            :rank                     => model.rank
          )
        end
      end
    end

    class Team < ActiveRecord::Base
      set_table_name :teams
      has_many :rosters, {
        :primary_key => :yahoo_key,
        :foreign_key => :yahoo_team_key
      }

      class << self
        def from_model(model)
          new(
            :yahoo_key        => model.team_key,
            :name             => model.name,
            :number_of_moves  => model.number_of_moves,
            :number_of_trades => model.number_of_trades
          )
        end
      end
    end

    # TODO Rename this RosterSpot
    class Roster < ActiveRecord::Base
      set_table_name :rosters
      belongs_to :player, :foreign_key => :yahoo_player_key, :primary_key => :yahoo_key
      belongs_to :team, :foreign_key => :yahoo_team_key, :primary_key => :yahoo_key

      class << self
        def from_model(team_key, model)
          # Assumes something like:
          #  Scout::Resource.league + 'teams' + 'roster'+ {:type => 'week', :week => 3} + 'players' + 'ownership'
          roster = new(
            :yahoo_team_key   => team_key,
            :yahoo_player_key => model.player_key,
            :week             => model.selected_position.week,
            :position         => model.selected_position.position
          )

          roster.playing_status = model.status if model.status?

          roster
        end
      end
    end

    class GameWeek < ActiveRecord::Base
      set_table_name :game_weeks
    end

    class RosterAdd < ActiveRecord::Base
      set_table_name :roster_adds
    end

    class Transaction < ActiveRecord::Base
      self.inheritance_column = :not_using_sti

      set_table_name :transactions
      belongs_to :add_roster_change, {
        :class_name => "Scout::Cache::RosterChange",
        :autosave   => true,
        :dependent  => :delete
      }
      belongs_to :drop_roster_change, {
        :class_name => "Scout::Cache::RosterChange",
        :autosave   => true,
        :dependent  => :delete
      }

      class << self
        def from_model(model)
          transaction = new(
            :yahoo_key => model.transaction_key,
            :timestamp => model.timestamp
          )

          transaction.type = model.type
          transaction.bid  = model.faab_bid if model.faab_bid?

          roster_changes = model.players.map do |player|
            Scout::Cache::RosterChange.from_model(player)
          end

          transaction.add_roster_change  = roster_changes.find(&:add?)
          transaction.drop_roster_change = roster_changes.find(&:drop?)

          transaction
        end
      end

      def type
        self[:type]
      end
    end

    class RosterChange < ActiveRecord::Base
      self.inheritance_column = :not_using_sti

      belongs_to :player, :foreign_key => :yahoo_player_key, :primary_key => :yahoo_key, :class_name => "Scout::Cache::Player"
      belongs_to :source_team, :foreign_key => :source_team_key, :primary_key => :yahoo_key, :class_name => "Scout::Cache::Team"
      belongs_to :destination_team, :foreign_key => :destination_team_key, :primary_key => :yahoo_key, :class_name => "Scout::Cache::Team"

      set_table_name :roster_changes

      class << self
        def from_model(model)
          transaction_data = model.transaction_data

          change = new(
            :yahoo_player_key => model.player_key,
            :source_type      => transaction_data.source_type,
            :destination_type => transaction_data.destination_type
          )

          change.type = transaction_data['type'] # Hash notation because of Object#type

          if transaction_data.destination_team_key?
            change.destination_team_key = transaction_data.destination_team_key
          end

          if transaction_data.source_team_key?
            change.source_team_key = transaction_data.source_team_key
          end

          change
        end
      end

      def type
        self[:type]
      end

      def add?
        type == 'add'
      end

      def drop?
        type == 'drop'
      end
    end

    class Stat < ActiveRecord::Base
      set_table_name :stats

      class << self
        def by_stat_id
          @stats ||= begin
            find(:all).inject({}) do |all, stat|
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

        def from_model(model)
          new(
            :stat_id       => model.stat_id,
            :name          => model.name,
            :sort_order    => model.sort_order,
            :position_type => position_type(model),
            :display_name  => model.display_name
          )
        end

        def position_type(model)
          case model.position_types.position_type
          when Array
            'ALL'
          when String
            model.position_types.position_type
          else
            raise "Unrecognized position type: #{model.position_types.inspect}"
          end
        end
      end

      def normalize_name
        name.gsub(' ', '_').downcase
      end
    end
  end
end