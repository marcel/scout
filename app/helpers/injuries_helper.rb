module InjuriesHelper
  def row_class(injury)
    case injury.game_status
    when /Probable/
      'success'
    when /Out/
      'error'
    when /Questionable/
      'warning'
    else
      if injury.injury =~ /Suspension/
        'error'
      else
        ''
      end
    end
  end
end
