module MatchupHelper
  def stat(name, stat_proc, comparison = @comparison)
    render partial: 'comparison', object: comparison, locals: {stat: stat_proc, name: name }
  end
end
