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
      content_tag(:strong, link_to(player.cached_owner.name, current_url(:owner => player.owner_key)))
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

    button_class = if player.cached_watches.any?
      if player.cached_watches.first.voted_up?
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

    current = position_type.to_s

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

  def weeks_in_season(week, season_view = false)
    current = GameWeek.current.week
    active = (week || current).to_i
    active = -1 if season_view
    label = ->(number) {
      if number == active
        'active'
      elsif current < number
        'disabled'
      else
        ''
      end
    }

    weeks = (1..17).inject({}) do |h, number|
      h[number] = label.(number)
      h
    end

    render partial: "shared/weeks_in_season", locals: {weeks: weeks}
  end

  def current_url(parameters_to_add)
    url_for(params.merge(parameters_to_add))
  end

  def player_performance_chart(player, options = {})
    # TODO Rather than using group here to ensure there is only 1 data point per week, figure out if the
    # chart can show multiple data points per week in case projections changed over a week
    points      = player.points.order(week: :asc, updated_at: :desc).group(:week)
    projections = player.projections.order(week: :asc, updated_at: :desc).group(:week)
    weeks = points.map {|point| "Week #{point.week} vs #{player.opponent_on_week(point.week) ||'bye'}" }
    # Do something better than this.
    if points.last.week == GameWeek.current.week && points.last.total.zero? && Time.now.wday < 7
      points = points[0...-1]
    end
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title text: "Weekly points versus projected"
      f.plotOptions(series: {dashStyle: 'ShortDot', dataLabels: {enabled: true}}, xAxis: {labels: {useHTML: true}})
      f.yAxis(title: {text: "Points"}, min: -5, max: 35, minPadding: 0, maxPadding: 0, startOnTick: false, tickInterval: 5)
      f.chart(borderWidth: 1, borderColor: '#aaa', height: options[:height] || 500)
      f.options[:xAxis][:categories] = weeks
      f.series(allowPointSelect: true, type: 'spline', name: 'Actual points', data: points.map(&:total), color: '#3a87ad', dashStyle: 'Solid')
      f.series(type: 'spline', name: 'Projected High',    data: projections.map(&:standard_high), color: '#468847')
      f.series(type: 'spline', name: 'Projected Standard',data: projections.map(&:standard), color: '#f89406')
      f.series(type: 'spline', name: 'Projected Low',     data: projections.map(&:standard_low), color: '#b94a48')
    end
  end

  def season_performance_chart(player_point_totals_by_player)
    weeks = 1.upto(GameWeek.current.week).map {|week| "Week #{week}" }
    max = player_point_totals_by_player.values.flatten.max_by(&:total).total
    if min_filter = params[:min]
      player_point_totals_by_player = player_point_totals_by_player.select do |player, points|
        points.all? {|point| point.total >= min_filter.to_f || (point.week == GameWeek.current.week && point.total == 0.0)}
      end
    end

    LazyHighCharts::HighChart.new('graph') do |f|
      f.title text: "Weekly points by position"
      f.exporting(enabled: true)

      f.plotOptions(series: {dashStyle: 'ShortDot', dataLabels: {enabled: true}}, xAxis: {labels: {useHTML: true}})
      f.yAxis(title: {text: "Points"}, min: -5, max: max, startOnTick: false, tickInterval: 5)
      f.chart(borderWidth: 1, borderColor: '#aaa', spacingRight: 20, height: 500)
      f.legend(align: 'right', verticalAlign: 'top', width: 150)
      f.options[:xAxis][:categories] = weeks
      sorted = player_point_totals_by_player.sort_by {|player, points| -points.map(&:total).sum }
      sorted.first((params[:limit] || 10).to_i).each do |player, points|
        name = player.owner_key.nil? ? "<em>#{player.full_name}</em>" : player.full_name
        name_with_points = "#{name}: %0.1f" % points.map(&:total).sum
        f.series(allowPointSelect: true, type: 'spline', name: name_with_points, data: points.sort_by(&:week).map(&:total), dashStyle: 'Solid')
      end
    end
  end


  def player_receiving_performance_chart(player)
    performances = player.offensive_performances.sort_by {|o| o.game_in_season.wk }
    weeks = performances.map do |performance|
      "Week #{performance.game_in_season.wk} vs #{player.opponent_on_week(performance.game_in_season.wk)}"
    end

    LazyHighCharts::HighChart.new('graph') do |f|
      f.title text: "Weekly receiving performance"
      f.plotOptions(series: {dashStyle: 'Solid', dataLabels: {enabled: true, color: '#000'}}, xAxis: {labels: {useHTML: true}})
      f.yAxis(min: -5, max: 20, minPadding: 0, maxPadding: 0, startOnTick: false, tickInterval: 5)
      f.chart(borderWidth: 1, borderColor: '#aaa', height: 500)
      f.options[:xAxis][:categories] = weeks

      f.series(type: 'column', color: '#3a87ad', name: 'Targets', data: performances.each_with_index.map do |performance, index|
        label = weeks[index]

        if team_performance = performance.team_performance
          team_pass_attempts = team_performance.pa
          percent = performance.trg.to_f / team_pass_attempts * 100
          label = label + "<br />#{performance.trg} targets of #{team_pass_attempts} attempts (#{percent.round(1)}%)"
          [label, performance.trg]
        end

        [label, performance.trg]
      end)


      f.series(type: 'column', color: '#f89406', name: 'Receptions', data: performances.each_with_index.map do |performance, index|
        label = weeks[index]
        receiving_yards = performance.recy
        receptions      = performance.rec
        avg_yards_per_reception = receptions.zero? ? 0 : receiving_yards / receptions
        label = label + "<br />#{receiving_yards} total receiving yards<br />#{avg_yards_per_reception} avg yards per reception"
        [label, receptions]
      end)
       f.series(type: 'column',color: '#b94a48', name: 'Red zone targets', data: performances.map do |performance|
         if redzone_opportunity = performance.redzone_opportunity
           redzone_opportunity.trg
         else
           0
         end
       end)
       f.series(type: 'column', color: '#468847', name: 'Receiving TDs', data: performances.map(&:tdre))

       f.series(dataLabels: {enabled: false}, type: 'spline', dashStyle: 'ShortDot', color: '#3a87ad', name: 'League median targets', data: performances.map {|p| p.league_median(:trg)})
       f.series(dataLabels: {enabled: false},type: 'spline', dashStyle: 'ShortDot', color: '#f89406', name: 'League median receptions', data: performances.map {|p| p.league_median(:rec)})
       # f.series(type: 'spline', dashStyle: 'ShortDot', color: '#3a87ad', name: 'League median targets', data: performances.map {|p| p.league_median(:trg)})

     end
  end

  def player_rushing_performance_chart(player)
    performances = player.offensive_performances.sort_by {|o| o.game_in_season.wk }
    weeks = performances.map do |performance|
      "Week #{performance.game_in_season.wk} vs #{player.opponent_on_week(performance.game_in_season.wk)}"
    end

    LazyHighCharts::HighChart.new('graph') do |f|
      f.title text: "Weekly rushing performance"
      f.plotOptions(series: {dashStyle: 'Solid', dataLabels: {enabled: true, color: '#000'}}, xAxis: {labels: {useHTML: true}})
      f.yAxis(min: -5, max: 20, minPadding: 0, maxPadding: 0, startOnTick: false, tickInterval: 5)
      f.chart(borderWidth: 1, borderColor: '#aaa', height: 500)
      f.options[:xAxis][:categories] = weeks
      f.series(type: 'column',  name: 'Carries', data: performances.each_with_index.map do |performance, index|
        label = weeks[index]

        if team_performance = performance.team_performance
          team_rush_attempts = team_performance.ra
          percent = performance.ra.to_f / team_rush_attempts * 100

          team_rushing_yards = team_performance.ry
          percent_of_yards = performance.ry.to_f / team_rushing_yards * 100
          label = label +
            "<br />#{performance.ra} carries of #{team_rush_attempts} running plays (#{percent.round(1)}%)" +
            "<br />#{performance.ry} rushing yards of #{team_performance.ry} team total (#{percent_of_yards.round(1)}%)"
          [label, performance.ra]
        end
        [label, performance.ra]
      end)

      f.series(type: 'column',  name: 'Successful carries', data: performances.map(&:sra))
      f.series(type: 'column',  name: 'Rushing TDs', data: performances.map(&:tdr))
      f.series(type: 'column',color: '#b94a48', name: 'Red zone carries', data: performances.map do |performance|
        if redzone_opportunity = performance.redzone_opportunity
          redzone_opportunity.ra
        else
          0
        end
      end)
      f.series(type: 'column', color: '#b94a48', name: 'Fumbles', data: performances.map(&:fuml))
      f.series(type: 'spline', dashStyle: 'ShortDot', color: 'black', name: 'League median carries', data: performances.map {|p| p.league_median(:ra)})
    end
  end

  def player_passing_performance_chart(player)
    performances = player.offensive_performances.sort_by {|o| o.game_in_season.wk }
    weeks = performances.map do |performance|
      "Week #{performance.game_in_season.wk} vs #{player.opponent_on_week(performance.game_in_season.wk)}"
    end

    LazyHighCharts::HighChart.new('graph') do |f|
      f.title text: "Weekly passing performance"
      f.plotOptions(series: {dashStyle: 'Solid', dataLabels: {enabled: true, color: '#000'}}, xAxis: {labels: {useHTML: true}})
      f.yAxis(min: -5, max: 50, minPadding: 0, maxPadding: 0, startOnTick: false, tickInterval: 5)
      f.chart(borderWidth: 1, borderColor: '#aaa', height: 500)
      f.options[:xAxis][:categories] = weeks
      f.series(type: 'areaspline', name: 'Pass attempts', data: performances.map(&:pa))
      f.series(type: 'areaspline', name: 'Completions', data: performances.each_with_index.map do |performance, index|
        label = weeks[index]
        label = label + "<br />#{performance.py} total passing yards"
        [label, performance.pc]
      end)
      f.series(type: 'spline', name: 'Interceptions', data: performances.map(&:int))
      f.series(type: 'spline', name: 'Passing TDs', data: performances.map(&:tdp))
      f.series(type: 'spline', dashStyle: 'ShortDot', color: '#bbb', name: 'League median completions', data: performances.map {|p| p.league_median(:pc)})
     end
  end

  def render_player_performance_chart(player, options = {})
    high_chart("chart-#{player.id}", player_performance_chart(player, options))
  end
end
