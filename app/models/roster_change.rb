class RosterChange < ActiveRecord::Base
  self.inheritance_column = nil
  
  belongs_to :player, {
    :foreign_key => :yahoo_player_key, 
    :primary_key => :yahoo_key, 
    :class_name  => "Player"
  }, touch: true
  
  belongs_to :source_team, {
    :foreign_key => :source_team_key, 
    :primary_key => :yahoo_key, 
    :class_name  => "Team"
  }
  
  belongs_to :destination_team, {
    :foreign_key => :destination_team_key, 
    :primary_key => :yahoo_key, 
    :class_name  => "Team"
  }

  class << self
    def from_payload(payload)
      transaction_data = payload.transaction_data

      change = new(
        :yahoo_player_key => payload.player_key,
        :source_type      => transaction_data.source_type,
        :destination_type => transaction_data.destination_type
      )

      change.type = transaction_data['type'] # Hash notation because of Object#type

      if transaction_data.destination_team_key?
        change.destination_team_key = transaction_data.destination_team_key
      end

      if transaction_data.source_team_key?
        change.source_team_key = transaction_data.source_team_key
      end

      change
    end
  end

  def type
    self[:type]
  end

  def add?
    type == 'add'
  end

  def drop?
    type == 'drop'
  end
end
