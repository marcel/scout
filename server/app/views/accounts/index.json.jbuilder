json.array!(@accounts) do |account|
  json.extract! account, :username, :password
  json.url account_url(account, format: :json)
end
