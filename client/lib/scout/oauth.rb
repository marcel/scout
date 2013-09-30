module Scout
  class OAuth
    OAUTH_CLIENT_OPTIONS = %w[consumer_key consumer_secret token token_secret oauth_session_handle]
    
    attr_reader *OAUTH_CLIENT_OPTIONS
    attr_reader :config
    attr_accessor :access_token
    def initialize(config = Scout.api_config)
      @config           = config
      @consumer_key     = config[:consumer_key]   
      @consumer_secret  = config[:consumer_secret] 
      self.access_token = ::OAuth::AccessToken.new(consumer, config[:token], config[:token_secret])
      
      configure_http!
    end

    def fetch_verify_credentials
      # access_token.get('/1/account/verify_credentials.json')
    end

    # def authorized?
    #   oauth_response = fetch_verify_credentials
    #   oauth_response.class == Net::HTTPOK
    # end

    # def needs_to_authorize?
    #   token.nil? || secret.nil? || !authorized?
    # end

    # def to_hash
    #   OAUTH_CLIENT_OPTIONS.inject({}) do |hash, attribute|
    #     if value = send(attribute)
    #       hash[attribute] = value
    #     end
    #     hash
    #   end
    # end

    def configure_http!
      consumer.http.use_ssl     = true
      consumer.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    def consumer
      @consumer ||=
        ::OAuth::Consumer.new(
          config[:consumer_key],
          config[:consumer_secret],
          :site => 'https://api.login.yahoo.com',
          :request_token_path => '/oauth/v2/get_request_token',
          :access_token_path => '/oauth/v2/get_token',
          :authorize_path => '/oauth/v2/request_auth',
          :signature_method => 'HMAC-SHA1',
          :oauth_version => '1.0'
        )
    end

    def refresh!
      request_token = ::OAuth::RequestToken.new(consumer, access_token.token, access_token.secret)
      new_token     = ::OAuth::Token.new(access_token.token, access_token.secret)
      self.access_token = request_token.get_access_token(
        :oauth_session_handle => config[:oauth_session_handle],
        :token                => new_token
      )
      config.update(:token => access_token.token, :token_secret => access_token.secret)
    end
  end
end
