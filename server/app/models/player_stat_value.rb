class PlayerStatValue < ActiveRecord::Base
  belongs_to :stat, {
    foreign_key: :yahoo_stat_id,
    primary_key: :yahoo_stat_id,
    inverse_of: :values
  }
  belongs_to :player, {
    primary_key: :yahoo_key,
    foreign_key: :yahoo_player_key,
    inverse_of: :stats
  }
end