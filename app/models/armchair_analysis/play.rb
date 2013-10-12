class ArmchairAnalysis::Play < ActiveRecord::Base
  self.inheritance_column = nil
  
  belongs_to :game, {
    primary_key: :gid,
    foreign_key: :gid
  }
end