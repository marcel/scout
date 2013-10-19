class Stadium < ActiveRecord::Base
  module Type
    Dome            = 'Dome'.freeze
    OpenAir         = 'Open Air'.freeze
    RetractableRoof = 'Retractable Roof'.freeze
  end

  def open_air?
    type == Type::OpenAir
  end

  self.inheritance_column = nil
end
