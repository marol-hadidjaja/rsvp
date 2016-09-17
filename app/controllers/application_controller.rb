class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  protect_from_forgery with: :null_session
  before_filter :store_location
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    logger.debug "---------------------#{ exception.inspect }"
    render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
    # redirect_to exception.redirect_path, :alert => exception.message
  end

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

        if params[:controller] == "invitees"
          if params[:action] == "update_arrival_form"
            session[:event_id] = Invitee.find(params[:id]).event_id
          end
        end
      end
    end
  end
end
