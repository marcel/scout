class GameWeek < ActiveRecord::Base
  class << self
    attr_accessor :cache

    def current
      today = Time.zone.today
      cache[today] ||= where("start_date <= :today AND end_date >= :today", today: today).take!
    end
    
    def current?(week)
      current.week == week
    end
  end
  
  self.cache ||= {}
end
