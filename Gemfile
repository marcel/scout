source 'https://rubygems.org'

ruby "1.9.3"

gem 'rails', '4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'therubyracer', platforms: :ruby
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
gem 'bcrypt-ruby'

gem 'unicorn'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'rvm-capistrano'
  # Default capistrano-unicorn doesn't seem to work with latest capistrano
  # gem 'capistrano-unicorn', :require => false
  # gem 'capistrano-unicorn', :git => 'https://github.com/sosedoff/capistrano-unicorn.git', :branch => 'master', :require => false
end

gem 'debugger', group: [:development, :test]

# For Bootstrap
gem "twitter-bootstrap-rails"

# Scout dependencies explicitly listed until Scout is a gem
gem "hashie"
gem 'oauth'
gem 'nokogiri'
gem 'faster_xml_simple'
gem 'fantasy_football_nerd'

gem 'pry', group: [:development, :staging]
gem 'pry-rails', group: [:development, :staging]

gem 'lazy_high_charts'
gem 'will_paginate'

# Needs RMagick...
# gem 'sparklines'

gem 'mysql2'

# Doesn't work with associations that have custom primary/foreign_keys
#gem 'identity_cache'
gem 'cityhash', '0.8.0'

gem 'dalli'

gem 'rack-mini-profiler'

gem 'multi_fetch_fragments'

group :production do
  gem 'newrelic_rpm'
  gem 'unicorn-worker-killer'
end

gem 'rack-cache'
gem 'kgio'

gem 'numeric_array'

#gem 'forecast_io'
gem 'typhoeus'
gem 'oj'
gem 'multi_json'
gem 'faraday'

gem "lrucache"

gem 'devise'