require File.expand_path('../boot', __FILE__)
# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Scout
  module Server
    class Application < Rails::Application
      CACHE_VERSION = '3'

      # Settings in config/environments/* take precedence over those specified here.
      # Application configuration should go into files in config/initializers
      # -- all .rb files in that directory are automatically loaded.

      # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
      # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
      config.time_zone = 'Pacific Time (US & Canada)'

      # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
      # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
      # config.i18n.default_locale = :de

      # Disable the asset pipeline.
      config.assets.enabled = true

      config.autoload_paths += %W(#{config.root}/lib)
    end

    def load_models
      Application.initialize! unless Application.initialized?

      Dir[Rails.root + 'app/models/**/*.rb'].each do |model_file|
        require model_file
      end
    end
    module_function :load_models
  end
end

require 'array_ext'
require 'numeric_ext'
require 'hash_ext'
