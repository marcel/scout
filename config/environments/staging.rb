require File.dirname(__FILE__) + '/production'

config = Scout::Server::Application.config

# Production overrides
config.log_level = :debug
config.cache_classes = false
config.consider_all_requests_local = true
config.serve_static_assets = true
config.autoflush_log = true
