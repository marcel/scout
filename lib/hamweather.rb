class HAMWeatherClient
  API_ROOT = 'https://api.aerisapi.com'
  class << self
    attr_accessor :default_params, :default_connection

    def forecast(*args, &block)
      self.default_connection ||= new
      default_connection.forecast(*args, &block)
    end
  end

  self.default_params = {client_id: 'YkJmrOXJHqCkx5Ymuo7o8', client_secret: '9VsoAaq6r8b7DkgnID0G5DXg0TEMEx4bJ1F8Samw'}

  def forecast(id, params = {})
    forecast_url = File.join(API_ROOT, 'forecasts', id.to_s)

    forecast_response = get(forecast_url, params)

    if forecast_response.success?
      json = Hashie::Mash.new(MultiJson.load(forecast_response.body))
      # TODO Eliminate the need for this
      if result = json.try(:response).try(:first).try(:periods).try(:first)
        result
      end
    end
  end

  def connection
    @connection ||= Faraday.new do |builder|
      builder.adapter :typhoeus
      builder.use Faraday::Response::Logger
    end
  end

  private
    def get(path, params = {})
      params = self.class.default_params.merge(params || {})

      connection.get(path, params)
    end
end