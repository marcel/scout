json.array!(@projections) do |projection|
  json.extract! projection, 
  json.url projection_url(projection, format: :json)
end
