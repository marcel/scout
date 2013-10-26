class ArmchairAnalysis::Drive < ActiveRecord::Base
  RESULTS = {
    touchdowns: 'TD',
    field_goals: 'FG',
    missed_field_goals: 'MFG',
    blocked_field_goals: 'BLFG',
    safeties: 'SAF',
    punts: 'PUNT',
    blocked_punts: 'BLPU',
    interceptions: 'INT',
    fumbles: 'FUM',
    end_of_quarter: 'ENDQ',
    turnovers_on_downs: 'DWNS'
  }

  RESULTS.each do |name, result|
    scope name, -> { where(res: result) }
  end

  belongs_to :game, {
    primary_key: :gid,
    foreign_key: :gid
  }

  belongs_to :team, ->{ where(position: 'DEF') }, {
    primary_key: :armchair_analysis_team_name,
    foreign_key: :tname,
    class_name: '::Player'
  }

  scope :by_team, ->(team) {
    where(tname: team)
  }

  class << self
    def count_of_drives_by_team
      group(:tname).count
    end

    def drives_ending_in_field_goal_attempts_by_team
      field_goals.group(:tname).count
    end

    def percent_of_drives_ending_in_field_goals_by_team
      total_drives_by_team = count_of_drives_by_team
      drives_ending_in_field_goal_attempts_by_team.inject({}) do |hash, (team_abbr, field_goal_drives)|
        hash[team_abbr] = field_goal_drives.percent_of(total_drives_by_team[team_abbr])
        hash
      end
    end
  end

  # scope :count_by_team, -> { group(:tname).count }

  #scope :drives_ending_in_field_goals_by_team where(res: ArmchairAnalysis::Drive::RESULTS[:field_goals]).group(:tname).count
end
