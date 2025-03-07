Scout::Server::Application.configure do
  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both thread web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_assets = false # Enabled so rack-cache works
  #config.static_cache_control = "public, max-age=2592000"


  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  config.cache_store = :dalli_store, {compress: true, value_max_bytes: 5.megabytes}
  # config.cache_store = :memory_store, { size: 64.megabytes }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"


  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.default_url_options = {host: 'scoutrank.co'}
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
    authentication: :plain,
    address: "smtp.mailgun.org",
    port: 587,
    domain: "scoutrank.co",
    user_name: "postmaster@scoutrank.co",
    password: "1vutq-cxlsj2"
  }
  
  config.to_prepare { Devise::SessionsController.force_ssl }
  config.to_prepare { Devise::RegistrationsController.force_ssl }


  config.time_zone = "Pacific Time (US & Canada)" 
  config.active_record.default_timezone = :local
  
  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  config.autoflush_log = true

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  ENV['RAILS_CACHE_ID'] = ENV['RAILS_APP_VERSION'] = Scout::Server::Application::CACHE_VERSION

  # if Rails.root.to_s['releases'] && Rails.root.basename.to_s =~ /^\d+$/
  #   release_version = Rails.root.basename.to_s
  #   STDERR.puts "Setting RAILS_CACHE_ID and RAILS_APP_VERSION to '#{release_version}'"
  #   ENV['RAILS_CACHE_ID'] = ENV['RAILS_APP_VERSION'] = release_version
  # end
end
