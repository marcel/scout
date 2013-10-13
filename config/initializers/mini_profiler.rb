# Have Mini Profiler start in hidden mode - display with short cut (defaulted to 'Alt+P')
Rack::MiniProfiler.config.start_hidden = true if Rails.env.production?