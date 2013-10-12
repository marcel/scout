class Transaction < ActiveRecord::Base
  self.inheritance_column = nil # :not_using_sti
  
  belongs_to :add_roster_change, {
    :class_name => "RosterChange",
    :autosave   => true,
    :dependent  => :delete
  }
  belongs_to :drop_roster_change, {
    :class_name => "RosterChange",
    :autosave   => true,
    :dependent  => :delete
  }

  class << self
    def from_payload(payload)
      transaction = new(
        :yahoo_key => payload.transaction_key,
        :timestamp => payload.timestamp
      )

      transaction.type = payload.type
      transaction.bid  = payload.faab_bid if payload.faab_bid?

      roster_changes = payload.players.map do |player|
        RosterChange.from_payload(player)
      end

      transaction.add_roster_change  = roster_changes.find(&:add?)
      transaction.drop_roster_change = roster_changes.find(&:drop?)

      transaction
    end
  end

  def type
    self[:type]
  end
end
