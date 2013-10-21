class ApplicationController < ActionController::Base
  before_filter :authenticate_account!, except: :sign_in
  before_filter :configure_permitted_parameters, if: :devise_controller?

  # TODO This is disabled until I get it to work with http caching.
  #protect_from_forgery with: :exception
  before_filter :profile_if_requested
  #before_filter :log_memcache_if_requested

  # def log_memcache_if_requested
  #   if params.has_key?(:log_memcache)
  #     $log_memcache = params[:log_memcache] == '1'
  #     Rails.logger.info "[memcached] setting $log_memcache to #{$log_memcache}"
  #
  #     (class << Scout.cache; self end ).class_eval do
  #       def fetch(*args, &block)
  #         Rails.logger.info "[memcached] fetching #{args.join('/')}" if $log_memcache
  #         super
  #       end
  #     end
  #   end
  # end
  protected
  
  def configure_permitted_parameters
    [:sign_up, :account_update].each do |devise_action|
      devise_parameter_sanitizer.for(devise_action) << :phone_number
    end
  end

  def profile_if_requested
    if !Rails.env.production? || params[:profile]
      Rack::MiniProfiler.authorize_request
    end
  end

  SUPPORTED_FILTERS = Set.new([
    :above,
    :below,
    :game_status,
    :injury,
    :owner,
    :ownership_type,
    :position,
    :position_type,
    :practice_status,
    :rank_by,
    :sort,
    :team,
    :watched,
    :week
  ])
  
  def render_fresh(objects, *args)
    if @week && !GameWeek.current?(@week)
      fresh_when(etag: collection_etag(objects, *args), :public => true)
    end
  end
  
  def partial_cache_key(key_name, object, params_to_include = nil)
    prefix = params_cache_prefix(params_to_include)
    k = [current_account.id.to_s, prefix, key_name, object.try(:cache_key)].compact.join('/')
    Rails.logger.info "CACHE KEY: #{k}"
    k
  end
  helper_method :partial_cache_key

  def params_cache_prefix(params_to_include = nil)
    permitted_params = params_to_include ? SUPPORTED_FILTERS + Set.new(Array(params_to_include)) : SUPPORTED_FILTERS
    params_for_key = params.select {|k,v| permitted_params.include?(k.to_sym) }
    params_for_key.empty? ? nil : params_for_key.sort.map {|pair| pair.join(':') }.join(';')
  end

  def collection_cache_key(collection, params_to_include = nil)
    [ "account-#{current_account.id}",
      params_cache_prefix(params_to_include),
      CityHash.hash128(ActiveSupport::Cache.expand_cache_key(collection))
    ].compact.join('/')
  end
  helper_method :collection_cache_key

  def collection_etag(collection, params_to_include = nil)
    CityHash.hash128(
      current_account.id.to_s +
      controller_name   +
      action_name +
      collection_cache_key(collection, params_to_include)
    )
  end
end