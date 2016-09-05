class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  protect_from_forgery with: :null_session
  before_filter :store_location
  before_action :authenticate_user!

  def store_location
    unless params[:controller] == "sessions"
      if params[:controller] == "events"
        # /events/1
        if params[:event_id].present?
          session[:event_id] = params[:event_id]
        end

        if params[:action] == "show"
          session[:event_id] = params[:id]
        end
      else
        # /?event_id=1
        if params[:event_id].present?
          session[:event_id] = params[:event_id]
        end
      end
    end
  end
end
