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

  def player_ownership(player)
    case player.ownership_type
    when 'team'
      content_tag(:strong, link_to(player.owner.name, current_url(:owner => player.owner_key)))
    when 'waivers'
      content_tag(:em, link_to("Waivers (#{player.waiver_date.strftime('%-m/%-d')})", current_url(ownership_type: 'waivers')))
    when 'freeagents'
      content_tag(:em, link_to("Free agent", current_url(ownership_type: 'freeagents')))
    else
      ''
    end
  end
  
  def watch_button(player)
    watch_params = {id: player.id, upvote: 1}
    
    button_class = if player.watches.any? 
      if player.watches.first.voted_up?
        watch_params.delete(:upvote)
        'btn-success'
      else
        'btn-primary'
      end
    else
      'btn'
    end
    default_classes = "btn-mini pull-right watch-button-#{player.id}"
    button_classes = [button_class, default_classes].join(' ')
    onclick = %[
      button = $('.watch-button-#{player.id}');
    
      if (button.hasClass('btn-primary')) {
        button.addClass('btn-success').removeClass('btn-primary');
      } else if (button.hasClass('btn-success')) {
        button.addClass('btn').removeClass('btn-success');
      } else {
        button.addClass('btn-primary').removeClass('btn');
      }; return false;
    ]
    
    
    link_to(
      content_tag(:i, '', :class => 'icon-star'), 
      update_watch_path(watch_params), 
      {remote: true, :class => button_classes, onclick: onclick}
    )
  end

  def player_points_status(points)
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

    points_badge(points, badge_class)
  end

  def team_points_status(points)
    badge_class = case points
      when 100..0.1/0 # Infinity
        'success'
      when 85..99.9
        'info'
      when 75..84.9
        'default'
      when 50..74.9
        'warning'
      when (-0.1/0..49.0)
        'important'
      end

    points_badge(points, badge_class)
  end

  def points_badge(points, badge_class)
    content_tag(:span, points, class: "badge badge-#{badge_class}")
  end
  
  def expert_ranking_trend(expert_rank)
    icon = ''
    label = ''
    delta = ''
    if expert_rank.ranked_in_previous_week?
      previous_week_rank = expert_rank.previous_week.overall_rank
      if previous_week_rank > expert_rank.overall_rank
        icon = 'icon-arrow-up'
        delta = previous_week_rank - expert_rank.overall_rank
        
        label = delta >= 5 ? 'label-success' : 'label-info'
      elsif previous_week_rank < expert_rank.overall_rank
        icon = 'icon-arrow-down'
        delta =  expert_rank.overall_rank - previous_week_rank
        label = delta >= 5 ? 'label-important' : 'label-warning'
      end
    else
      icon = expert_rank.week == 1 ? '' : 'icon-leaf'
      label = ''
      delta = expert_rank.week == 1 ? '' : 'new'
    end
    
    css_class = delta.present? ? [icon, label, 'label'].select(&:present?).join(' ') : ''
      
    content_tag(:span, content_tag(:strong, " #{delta}"), style: "padding: 5px", :class => css_class)
      # <span style="padding: 5px" class="label label-success icon-arrow-up">&nbsp;<strong>5</strong></span>
  end
  
  def position_type_selector(position_type)
    mapping = {
      'quarterback'           => 'QB',
      'running-back'          => 'RB',
      'wide-receiver'         => 'WR', 
      'tight-end'             => 'TE',
      'kicker'                => 'K',
      'defense-special-teams' => 'DST'
    }
    
    current = position_type
    
    position_types = mapping.map do |type, display|
      label = if type == position_type
        'active'
      else
        ''
      end
      
      [type, display, label]
    end
    
    render partial: "shared/position_type_selector", locals: {position_types: position_types}
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
  
  def player_performance_chart(player)
    # TODO Rather than using group here to ensure there is only 1 data point per week, figure out if the 
    # chart can show multiple data points per week in case projections changed over a week
    points      = player.points.order(week: :asc, created_at: :desc).group(:week)
    projections = player.projections.order(week: :asc, created_at: :desc).group(:week)
    weeks = points.map {|point| "Week #{point.week}<br /> vs ATL " }
    # Do something better than this.
    if points.last.week == GameWeek.current.week && points.last.total.zero? && Time.now.wday < 5
      points = points[0...-1]
    end

    LazyHighCharts::HighChart.new('graph') do |f|
      f.title text: "Weekly points versus projected"
      f.plotOptions(series: {dashStyle: 'ShortDot', dataLabels: {enabled: true}}, xAxis: {labels: {useHTML: true}})
      f.yAxis(title: {text: "Points"}, min: -5, max: 35, minPadding: 0, maxPadding: 0, startOnTick: false, tickInterval: 5)
      f.chart(borderWidth: 1, borderColor: '#aaa', height: 500)
      f.options[:xAxis][:categories] = weeks
      f.series(allowPointSelect: true, type: 'spline', name: 'Actual points', data: points.map(&:total), color: '#3a87ad', dashStyle: 'Solid')
      f.series(type: 'spline', name: 'Projectd High',    data: projections.map(&:standard_high), color: '#468847')
      f.series(type: 'spline', name: 'Projectd Standard',data: projections.map(&:standard), color: '#f89406')
      f.series(type: 'spline', name: 'Projectd Low',     data: projections.map(&:standard_low), color: '#b94a48')
    end
  end
  
  def render_player_performance_chart(player)
    high_chart("chart-#{player.id}", player_performance_chart(player))
  end
end
