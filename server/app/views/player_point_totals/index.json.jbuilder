json.array!(@player_point_totals) do |player_point_total|
  json.extract! player_point_total, 
  json.url player_point_total_url(player_point_total, format: :json)
end
