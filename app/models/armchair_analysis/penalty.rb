class ArmchairAnalysis::Penalty < ActiveRecord::Base
  belongs_to :team, ->{ where(position: 'DEF') }, {
    foreign_key: :ptm,
    primary_key: :armchair_analysis_team_name,
    class_name: '::Player'
  }

  belongs_to :player, {
    foreign_key: :pem,
    primary_key: :armchair_analysis_team_name,
    class_name: '::Player'
  }

  CATEGORIES = [
    'False Start',
    'Offensive Holding',
    'Play Book Execution',
    'Defensive Line',
    'Defensive Secondary',
    'Dumb',
    'Poor Fundamentals (Blocking/Tackling)',
    'Other'
  ]

  def category
    CATEGORIES[cat + 1]
  end

  def declined?
    act == 'D'
  end

  def offsetting?
    act == 'O'
  end

  def accepted?
    act == 'A'
  end
end
