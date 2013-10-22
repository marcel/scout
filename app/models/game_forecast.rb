class GameForecast < ActiveRecord::Base
  belongs_to :game
  class << self
    def attributes_from_payload(payload)
      {
        coded:           payload.weatherPrimaryCoded,
        icon:            payload.icon,
        description:     payload.weatherPrimary,
        min_temp:        payload.minTempF,
        max_temp:        payload.maxTempF,
        temp_feels_like: payload.feelslikeF,
        humidity:        payload.humidity,
        pop:             payload.pop,
        wind_speed:      payload.windSpeedMPH,
        json:            payload.to_json
      }
    end
  end

  # [coverage]:[intensity]:[weather]
  CoverageCodes = {
    'D'  => 1000, # Definite
    'FQ' => 500,  # Frequent
    'L'  => 500,  # Likely
    'WD' => 250,  # Widespread
    'IN' => 50,   # Intermittent
    'NM' => 20,   # Numerous
    'O'  => 10,   # Occasional
    'PA' => 10,   # Patchy
    'SC' => 5,    # Scattered
    'PD' => 5,    # Periods of
    'IS' => 5,    # Isolated
    'C'  => 5,    # Chance of
    'S'  => 2,    # Slight chance
    'VC' => 2,    # In the vicinity / Nearby
    'AR' => 2,    # Areas of
    'BR' => 2     # Brief
  }

  IntensityCodes = {
    'VH' => 10000, # Very heavy
    'H'	 => 1000,  # Heavy
    'L'	 => 5,     # Light
    'VL' => 5      # Very light
  }

  WeatherCodes = {
    'A'  => 10, # Hail
    'BR' =>	5,  # Mist
    'BS' =>	25, # Blowing snow
    'F'  => 10, # Fog
    'FR' =>	10, # Frost
    'H'  => 5,  # Haze
    'IC' =>	20, # Ice crystals
    'IF' =>	20, # Ice fog
    'IP' =>	30, # Ice pellets / sleet
    'L'  => 20, # Drizzle
    'R'  => 30, # Rain
    'RW' =>	30, # Rain showers
    'RS' =>	40, # Rain/snow mix
    'SI' =>	50, # Snow/sleet mix
    'WM' =>	45, # Wintry mix
    'S'  => 50, # Snow
    'SW' =>	50, # Snow showers
    'T'  => 40, # Thunderstorms
    'ZF' =>	20, # Freezing fog
    'ZL' =>	25, # Freezing drizzle
    'ZR' =>	30, # Freezing rain
    'ZY' =>	30 # Freezing spray
  }

  def severity
    coverage_value * intensity_value * weather_value
  end

  def codes
    @codes ||= coded.split(':', 3)
  end

  def coverage_code
    codes[0]
  end

  def coverage_value
    CoverageCodes[coverage_code] || 1
  end

  def intensity_code
    codes[1]
  end

  def intensity_value
    IntensityCodes[intensity_code] || 1
  end

  def weather_code
    codes[2]
  end

  def weather_value
    WeatherCodes[weather_code] || 1
  end
end
