class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :profile_if_requested

  def profile_if_requested
    if !Rails.env.production? || params[:profile]
      Rack::MiniProfiler.authorize_request
    end
  end
end