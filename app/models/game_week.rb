class GameWeek < ActiveRecord::Base
  @cache ||= {}
  class << self
    def current
      today = Date.today
      key   = today.to_s
      game_week  = @cache[key] ||= where("start_date <= :today AND end_date >= :today", today: Date.today).take
      today.wday < 4 ? game_week.week - 1 : game_week.week
    end
    
    def current?(week)
      current == week
    end
  end
end
