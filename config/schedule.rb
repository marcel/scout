set :output, "#{path}/log/cron.log"

every 15.minutes do
  runner "Game.update_forecasts"
end

every 30.minutes do
  runner 'Team.import'
  runner 'RosterSpot.import'
end

every 3.hours do
  runner 'Player.import'
end

every :day, at: %w[13 19 23] do
  runner 'Injury.import'
  runner 'Projection.import'
end

every :friday, at: '6 am' do
  runner 'PlayerPointTotal.import'
end

every :sunday, at: (17..23).to_a.map(&:to_s) do
  runner 'PlayerPointTotal.import'
end

every :monday, at: %w[1am 2am 3am 4am 5am 6am] do
  runner 'PlayerPointTotal.import'
end

every :tuesday, at: %[1am 2am 3am 4am 5am] do
  runner 'PlayerPointTotal.import'
end

every [:thursday, :friday, :saturday], at: %w[13 19 23] do
  runner 'ExpertRank.import'
end