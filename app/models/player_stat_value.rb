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
  }, touch: true

  def points
    PointCalculationByStatId[yahoo_stat_id].try(:call, value) || 0.0
  end

  PointCalculationByStatId = {
    4  => ->(yards) { yards.to_f / 25.0 },
    5  => ->(tds) { tds * 4 },
    6  => ->(ints) { ints * -1 },
    9  => ->(yards) { yards.to_f / 10.0 },
    10 => ->(tds) { tds * 6 },
    12 => ->(yards) { yards.to_f / 10.0 },
    13 => ->(tds) { tds * 6 },
    14 => ->(yards) { yards.to_f / 30.0 },
    15 => ->(tds) { tds * 6 },
    16 => ->(conv) { conv * 2 },
    18 => ->(fum) { fum * -2 },
    19 => ->(fg) { fg * 3 },
    20 => ->(fg) { fg * 3 },
    21 => ->(fg) { fg * 3 },
    22 => ->(fg) { fg * 4 },
    23 => ->(fg) { fg * 5 },
    32 => ->(sacks) { sacks * 1 },
    33 => ->(ints) { ints * 2 },
    34 => ->(fum) { fum * 2 },
    35 => ->(tds) { tds * 6 },
    36 => ->(safeties) { safeties * 2 },
    37 => ->(blocks) { blocks * 2 },
    49 => ->(return_tds) { return_tds * 6 },
    50 => ->(points) { 10 },
    51 => ->(points) { 7 },
    52 => ->(points) { 4 },
    53 => ->(points) { 1 },
    54 => ->(points) { 0 },
    55 => ->(points) { -1 },
    56 => ->(points) { -4 },
    57 => ->(tds) { tds * 6 }
  }
end