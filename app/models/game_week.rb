class GameWeek < ActiveRecord::Base
  class << self
    def current
      @cache ||= {}
      today = Date.today
      @cache[today] ||= where("start_date <= :today AND end_date >= :today", today: Date.today).take!
    end
    
    def current?(week)
      current.week == week
    end
  end
end
