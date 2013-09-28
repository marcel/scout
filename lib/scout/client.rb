module Scout
  class Client
    API_ROOT_URL = 'http://fantasysports.yahooapis.com/fantasy/v2'
    
    attr_reader :oauth
    def initialize(oauth = Scout::OAuth.new)
      @oauth = oauth
    end

    def get(resource, *options, &block)
      response = oauth.access_token.get(File.join(API_ROOT_URL, resource), *options)
      if response.code_type == Net::HTTPOK
        Response.new(Nokogiri::XML(response.body), resource)
      else
        response.error!
      end
    rescue ::OAuth::Problem => e
      if e.message =~ /token_expired/
        oauth.refresh!
        retry
      else
        raise e
      end
    end
    
    DEFAULT_TRANSACTION_TYPES = %w[add trade drop]
    
    # TODO waiver and pending trade with team key
    def transactions(options = {})
      types = (options[:types] || DEFAULT_TRANSACTION_TYPES).join(',')
      
      request(Resource.league / 'transactions' + {:types => types}) do |result|
        result.transactions.map do |transaction| 
          Transaction.new(transaction)
        end
      end
    end
    
    def roster(week = nil)
      week_parameters = week ? {:type => 'week', :week => week} : {}
      resource        = Resource.league + 'teams' + 'roster'+ week_parameters + 'players'
      
      request(resource) do |result|
        result.teams.map do |team|
          team_key = Team.new(team).team_key
          team.css('player').map do |player|
            Scout::Cache::Roster.from_model(
              team_key, 
              Scout::Player.new(player)
            )
          end
        end.flatten
      end
    end
    
    def team(key = Resource::TEAM_KEY)
      Team.new(request(Resource.team(key)).team)
    end
    
    def teams
      request(Resource.league + 'teams') do |result|
        result.teams.map {|team| Team.new(team) }
      end
    end
    
    def player(key, parameters = {})
      Player.new(request(Resource.player(key) + parameters).player)
    end
    
    def stats
      request(Resource.game + 'stat_categories') do |result|
        result.css('stat').map {|stat| Stat.new(stat) } # TODO Figure out why result.stats doesn't work
      end
    end
    
    MAX_RESULTS_PER_REQUEST = 25
    
    # Example request: All available players who are wide receivers/running backs/tight ends, sorted by points this season
    # 
    #   players(:start => 0, :status => 'A', :position => 'WR,RB,TE', :sort => 'PTS', :sort_type => 'season')
    def players(parameters = {}, options = {})
      request(Resource.league + 'players' + parameters, options) do |result|
        result.players.map {|player| Player.new(player) }
      end
    end
    
    def request(resource, options = {}, &block)
      p resource.uri

      results = block_given? ? yield(get(resource)) : get(resource)
            
      if resource.start? && results.size == MAX_RESULTS_PER_REQUEST && !(options.has_key?(:max) && resource.start.to_i + MAX_RESULTS_PER_REQUEST >= options[:max])
        start_for_next_request = resource.start.to_i + MAX_RESULTS_PER_REQUEST
        results + request(resource + {:start => start_for_next_request}, options, &block)
      else
        if max = options[:max]
          results.first(MAX_RESULTS_PER_REQUEST - (resource.start.to_i + MAX_RESULTS_PER_REQUEST - max))
        else
          results
        end
      end
    end
  end
end