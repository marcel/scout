module ApplicationHelper
  def player_profile(player, path = nil, include_probably = false)
    render partial: 'players/profile', :locals => {
      player: player, 
      path:  path ? link_to(player.full_name, path) : player.full_name
      
    }
  end
  
  def player_playing_status(player)
    text, label = case player.playing_status
      when Player::PlayingStatus::Questionable
        ['Questionable', 'warning']
      when Player::PlayingStatus::Out
        ['Out', 'important']
      when Player::PlayingStatus::InjuredReserve
        ['Injured Reserve', 'important']
      when Player::PlayingStatus::NotActive
        ['Not Active', 'important']
      when Player::PlayingStatus::Probable
        ['Probable', 'success']
      else
        []
      end
      
    if text && label
      link_to(content_tag(:div, 
        text, 
        class: "label label-#{label}"
      ),  current_url(game_status: text))
    else
      ''
    end
  end
  
  def points_status(points)
    badge_class = case points
      when 25..0.1/0 # Infinity
        'success'
      when 15..24.9
        'info'
      when 6..14.9
        'default'
      when 2..5.9
        'warning'
      when (-0.1/0..1.9)
        'important'
      end
      
    content_tag(:span, points, class: "badge badge-#{badge_class}")
  end
  
  def weeks_in_season(week)
    current = GameWeek.current.week
    active = (week || current).to_i
    label = ->(number) {
      if number == active
        'active'
      elsif current < number
        'disabled'
      else
        ''
      end
    }
    
    weeks = (1..16).inject({}) do |h, number|
      h[number] = label.(number)
      h
    end    
    
    render partial: "shared/weeks_in_season", locals: {weeks: weeks}
  end
  
  def current_url(parameters_to_add)
    url_for(params.merge(parameters_to_add))
  end
end
