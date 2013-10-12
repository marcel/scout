json.array!(@injuries) do |injury|
  json.extract! injury, 
  json.url injury_url(injury, format: :json)
end
