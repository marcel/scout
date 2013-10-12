source 'https://rubygems.org'

ruby "1.9.3"

gem 'rails', '4.0.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
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
# gem 'bcrypt-ruby', '~> 3.0.0'

gem 'unicorn'

group :development do
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'rvm-capistrano'
  # Default capistrano-unicorn doesn't seem to work with latest capistrano
  # gem 'capistrano-unicorn', :require => false
  # gem 'capistrano-unicorn', :git => 'https://github.com/sosedoff/capistrano-unicorn.git', :branch => 'master', :require => false
end

group :assets do
  gem 'turbo-sprockets-rails3'
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

gem 'pry'
gem 'pry-rails', group: :development

gem 'lazy_high_charts'
gem 'will_paginate'

# Needs RMagick...
# gem 'sparklines'

gem 'mysql2'
