require 'hamweather'
module Scout
  class << self
    attr_reader :weather
  end
  
  @weather = HAMWeatherClient.new
end