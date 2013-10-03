json.array!(@rosters) do |roster|
  json.extract! roster, 
  json.url roster_url(roster, format: :json)
end
