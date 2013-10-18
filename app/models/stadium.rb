class Stadium < ActiveRecord::Base
  module Type
    Dome            = 'Dome'.freeze
    OpenAir         = 'Open Air'.freeze
    RetractableRoof = 'Retractable Roof'.freeze
  end
  
  self.inheritance_column = nil
end
