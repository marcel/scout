json.array!(@teams) do |team|
  json.extract! team, 
  json.url team_url(team, format: :json)
end
