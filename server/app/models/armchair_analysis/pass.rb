class ArmchairAnalysis::Pass < ActiveRecord::Base
  belongs_to :completion, {
    foreign_key: :pid,
    primary_key: :pid
  }
  
  belongs_to :play, {
    foreign_key: :pid,
    primary_key: :pid
  }
  
  has_one :game, :through => :play
end
