class RosterSpot < ActiveRecord::Base
  belongs_to :player, :foreign_key => :yahoo_player_key, :primary_key => :yahoo_key
  belongs_to :team, :foreign_key => :yahoo_team_key, :primary_key => :yahoo_key

  class << self
    def from_payload(team_key, payload)
      # Assumes something like:
      #  Scout::Resource.league + 'teams' + 'roster'+ {:type => 'week', :week => 3} + 'players' + 'ownership'
      roster = new(
        :yahoo_team_key   => team_key,
        :yahoo_player_key => payload.player_key,
        :week             => payload.selected_position.week,
        :position         => payload.selected_position.position
      )

      roster.playing_status = payload.status if payload.status?

      roster
    end
  end
end
