module Scout
  class Resource
    GAME_KEY   = 314
    LEAGUE_KEY = '314.l.489038'
    TEAM_KEY   = '314.l.489038.t.4'

    class << self
      def game(key = GAME_KEY)
        new('game', key)
      end

      def league(key = LEAGUE_KEY)
        new('league', key)
      end
      
      def players(key = LEAGUE_KEY)
        league(key) + 'players'
      end

      def team(key = TEAM_KEY)
        new('team', key)
      end
      
      def roster(key = TEAM_KEY)
        team(key) + 'roster'
      end

      def player(key)
        new('player', key)
      end
    end

    RESOURCES = {
      :game        => Set.new(%w[metadata leagues players game_weeks stat_categories position_types roster_positions]),
      :league      => Set.new(%w[metadata settings standings scoreboard teams players draftresults transactions]),
      :team        => Set.new(%w[metadata stats standings roster draftresults matchups]),
      :roster      => Set.new(%w[players]),
      :player      => Set.new(%w[metadata stats ownership percent_owned draft_analysis ranks]),
      :transaction => Set.new(%w[metadata players]),
      :user        => Set.new(%w[games games/leagues games/teams])
    }

    RESOURCES.merge!(
      :games        => RESOURCES[:game] + ['teams'],
      :leagues      => RESOURCES[:league],
      :teams        => RESOURCES[:team],
      :players      => RESOURCES[:player],
      :transactions => RESOURCES[:transaction],
      :users        => RESOURCES[:user]
    )

    class Parameters < Hash
      def to_s
        if empty?
          ''
        else
          assignments = sort_by {|k, v| k.to_s }.map do |name, value|
            [name, value].compact.join('=')
          end

          ";" + assignments.join(";")
        end
      end
    end

    attr_reader :name
    attr_accessor :parameters, :key, :sub_resource
    def initialize(name, key = nil, parameters = {})
      @name         = name
      @key          = key
      @parameters   = Parameters.new(parameters)
      @sub_resource = nil
    end

    def uri
      base = [name, key].compact.join("/") + parameters.to_s
      sub_resource ? [base, sub_resource.uri].join('/') : base
    end

    def +(input)
      case input
      when Resource
        self / input
      when String
        if valid_sub_resources.include?(input)
         self / Resource.new(input)
        else
         key, value = input.split('=')
         self + { key.to_sym => value }
        end
      when Hash
        input.each do |parameter, value|
          send("#{parameter}=", value)
        end
      else
        self + input.to_str
      end

      self
    end
    
    def /(input)
      case input
      when Resource
        current_resource.sub_resource = input
      when String
        if valid_sub_resources.include?(input)
          self / Resource.new(input)
        else
          raise IllegalArgumentException, "`#{input}` is not a valid sub-resource for `#{name}`"
        end
      else
        self / input.to_str
      end
      
      self
    end

    def current_resource
      resources.last
    end

    def valid_sub_resources
      RESOURCES[current_resource.name.to_sym] || Set.new
    end

    def valid_filters
      raise "Implemented in concrete sub classes"
    end

    def resources
      sub_resource ? [self, sub_resource.resources].flatten.compact : [self]
    end

    def ==(other_resource)
      other_resource.is_a?(self.class) && uri == other_resource.uri
    end

    def to_s
      uri
    end

    def to_str
      to_s
    end

    private
      def method_missing(method, *args, &block)
        # resource.parameter_name = value
        if method.to_s[/\w+=$/] && args.size == 1
          parameter = method.to_s[/(\w+)=$/, 1].to_sym
          resource_with_parameter = begin
            if resource = resources.reverse.detect {|r| r.parameters.has_key?(parameter.to_sym) }
              resource
            else
              current_resource
            end
          end

          resource_with_parameter.parameters[parameter] = args.first.to_s
        # resource.parameter_is_defined?
        elsif parameter = method.to_s[/(\w+)\?$/, 1]
          resources.any? do |resource|
            resource.parameters.has_key?(parameter.to_sym)
          end
        # get_resource_by_name
        elsif resource = resources.detect {|r| r.name == method.to_s }
          resource
        # resource.get_parameter_value
        elsif resource = resources.detect {|r| r.parameters.has_key?(method.to_sym) }
          resource.parameters[method.to_sym]
        else
          super
        end
      end

      class Game < Resource
        def initialize(key = GAME_KEY)
          super('game', key)
        end
      end

      class League < Resource
        def initialize(key = LEAGUE_KEY)
          super('league', key)
        end
      end

      class Team < Resource
        def initialize(key = TEAM_KEY)
          super('team', key)
        end
      end

      class Player < Resource
        def initialize(key)
          super('player', key)
        end
      end

      class Players < Resource
        def initialize
          super('players')
        end

        def valid_filters
          [
            Filter::Position,
            Filter::Status,
            Filter::Search,
            Filter::Sort,
            Filter::SortType,
            Filter::SortSeason,
            Filter::SortWeek,
            Filter::Start,
            Filter::Count
          ]
        end
      end

      class Filter
        attr_reader :name, :values, :examples
        def initialize(name, values, examples)
          @name     = name
          @values   = values
          @examples = examples
        end

        def to_doc
          # TODO
        end

        def to_param(value)
          [name, value].join('=')
        end

        Position = new(
          'position',
          'Valid player positions',
          %w[QB WR TE RB] # TODO list all of them
        )

        Status = new(
          'status',
          'Player status',
          ['A (all available players)',
           'FA (free agents only)',
           'W (waivers only)',
           'T (all taken players)',
           'K (keepers only)']
        )

        Search = new(
          'search',
          'player name',
          %w[smith]
        )

        Sort = new(
          'sort',
          'sorting criteria',
          ['{stat_id} (e.g. 60)',
           'NAME (last, first)',
           'OR (overall rank)',
           'AR (actual rank)',
           'PTS (fantasy points)']
        )

        SortType = new(
          'sort_type',
          'time range that sorting is performed over (used in conjunction with "sort")',
          %w[season week lastmonth]
        )

        SortSeason = new(
          'sort_season',
          'the season to sort (used in conjuction with "sort" and "sort_type=season")',
          %w[2013]
        )

        SortWeek = new(
          'sort_week',
          'the week to sort (used in conjunction with "sort" and "sort_type=week")',
          %w[4]
        )

        Start = new(
          'start',
          'Any integer 0 or greater; used for paginating',
          %w[0 50]
        )

        Count = new(
          'count',
          'Any integer 0 or greater (N.B. can not be greater than 25, the default)',
          %w[1 25]
        )
      end
  end
end