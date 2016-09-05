class SessionsController < Devise::SessionsController
  layout false
  #layout :layout

  def destroy
    event_id = session[:event_id]
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    session[:event_id] = event_id
    redirect_to new_user_session_path
  end

  private

  def layout
    # only turn it off for login pages:
    logger.debug "----------------------#{ is_a?(Devise::SessionsController) }"
    is_a?(Devise::SessionsController) ? false : "application"
    # or turn layout off for every devise controller:
    devise_controller? && "application"
  end

  # before_filter :configure_sign_in_params, only: [:create]
  before_filter :set_object, only: [:new]

  def set_object
    if session[:event_id].present?
      @event = Event.find(session[:event_id])
    end
  end

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
