#require 'google/api_client'
require 'google/api_client/client_secrets'
#require 'google/api_client/auth/installed_app'
#require 'googleauth/stores/file_token_store'
#require 'google/api_client/auth/storage' #bermasalah
#require 'google/api_client/auth/storages/file_store' #bermasalah
require 'fileutils'
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/web_user_authorizer'
#require 'googleauth/stores/file_token_store'
require 'googleauth/stores/redis_token_store'
require 'redis'
require 'rqrcode'
require 'rqrcode_png'
#require 'multi_json'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'
CLIENT_SECRETS_PATH = File.join(Dir.home, 'rsvp', 'client_id-quickstart.json')
CREDENTIALS_PATH = File.join(Dir.home, '.credentials', "calendar-ruby-quickstart.json")
#SCOPE = "https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/userinfo.email"
SCOPE = ["https://www.googleapis.com/auth/calendar", "https://www.googleapis.com/auth/userinfo.email"]
=begin
client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
#authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
authorizer = Google::Auth::WebUserAuthorizer.new(client_id, scope, token_store, '/oauth2callback')
=end

class EventsController < ApplicationController
  #before_action :setgoogleauth

  skip_before_filter :authenticate_user!, :only => :images

  def index
=begin
  <Event id: 1, user_id: 1, name: "gh", event_id: "3edbr26rpgoioaq3r5g4tbulk4", description: "gh",
    location: "gh", start: "2016-10-08 10:00:00", end: "2016-10-08 12:00:00", created_at: "2016-08-04 15:20:25",
    updated_at: "2016-08-04 15:20:26">
  <Event id: 2, user_id: 1, name: "married", event_id: "0p8r60aoe3f9huq9q78nch0dss", description: "married",
    location: "n", start: "2016-10-08 10:00:00", end: "2016-10-08 12:00:00", created_at: "2016-08-08 16:43:40",
    updated_at: "2016-08-08 16:43:41">]
=end
    #unless session.has_key?(:credentials)
    #  redirect_to('/oauth2callback')
    #else
=begin
      client_opts = JSON.parse(session[:credentials])
      auth_client = Signet::OAuth2::Client.new(client_opts)
      logger.debug "--------------------------auth_client: #{auth_client.inspect}"
      calendar_api = auth_client.discovered_api('calendar', 'v3')

      results = client.execute!(
        :api_method => calendar_api.events.list,
        :parameters => {
        :calendarId => 'primary',
        :maxResults => 10,
        :singleEvents => true,
        :orderBy => 'startTime',
        :timeMin => Time.now.iso8601 })
      "<pre>#{JSON.pretty_generate(results.to_h)}</pre>"
=end

=begin
      # WORKED
      client_opts = JSON.parse(session[:credentials])
      auth_client = Signet::OAuth2::Client.new(client_opts)
      client = Google::Apis::CalendarV3::CalendarService.new
      client.authorization = auth_client
      event = Google::Apis::CalendarV3::Event.new({
        summary: 'Google I/O 2015',
        location: '800 Howard St., San Francisco, CA 94103',
        description: 'A chance to hear more about Google\'s developer products.',
        start: {
          date_time: '2016-10-08T16:00:00+07:00',
          time_zone: 'Asia/Bangkok',
        },
        end: {
          date_time: '2016-10-08T19:00:00+07:00',
          time_zone: 'Asia/Bangkok',
        },
        attendees: [
          { email: 'lpage@example.com' },
          { email: 'sbrin@example.com' },
        ]
      })
      logger.debug "----------------------------------------auth_client: #{ auth_client.inspect }"
      logger.debug "----------------------------------------client: #{ client.inspect }"
      result = client.insert_event('primary', event, send_notifications: true)
      puts "Events created: #{result.inspect}"
=end
    #end
    if current_user.has_role?("invitee")
      redirect_to event_path(current_user.events.first)
      # @events = current_user.events.order("created_at DESC")
    elsif current_user.has_role?("receptionist")
      redirect_to event_invitees_path(current_user.events.first)
    elsif current_user.has_role?("admin")
      if current_user.events.empty?
        redirect_to new_event_path
      else
        @events = current_user.events.order("created_at DESC")
      end
    else
      # new user with no roles
      redirect_to new_event_path
    end
  end

  def new
    @event = Event.new
  end

  def create
    unless session.has_key?(:credentials)
      session[:event] = event_params
      redirect_to('/oauth2callback')
    else
      if session[:event]
        @event = Event.new(session[:event])
      else
        @event = Event.new(event_params)
      end

      respond_to do |format|
        # logger.debug "----------------------------#{session[:credentials].inspect}"
        if @event.save
          #client = Google::APIClient.new(:application_name => APPLICATION_NAME)
=begin
          # RIGHT
          client_opts = JSON.parse(session[:credentials])
          auth_client = Signet::OAuth2::Client.new(client_opts)
          client = Google::Apis::CalendarV3::CalendarService.new
          client.authorization = auth_client
=end
          #client.authorization = authorize
          #calendar_api = client.discovered_api('calendar', 'v3')
=begin
          # RIGHT
          @new_event = Google::Apis::CalendarV3::Event.new({
            summary: @event.name,
            description: @event.description,
            location: @event.location,
            start: { date_time: @event.start.to_datetime,
                     time_zone: 'Asia/Bangkok' },
                     end: { date_time: @event.end.to_datetime,
                   time_zone: 'Asia/Bangkok' },
            guestsCanInviteOthers: false,
            guestsCanSeeOtherGuests: false
          })

          logger.debug "------------------------------------#{@new_event.inspect}"
=end
=begin
          if @g_event = client.execute(:api_method => calendar_api.events.insert,
                                        :parameters => { 'calendarId' => 'primary', 'sendNotifications' => true },
                                        :body => JSON.dump(@new_event),
                                        :headers => { 'Content-Type' => 'application/json' })
            logger.debug "------------------------#{ @g_event.body }"
            format.html { redirect_to invitees_path }
          end
=end
=begin
          # RIGHT
          if result = client.insert_event('primary', @new_event, send_notifications: true)
            logger.debug "--------------------------#{result.inspect}"
            session.delete(:event)
            format.html { redirect_to invitees_path }
          end
=end
          if insert_event(@event) == 1
            if !params[:event_images].nil? && !params[:event_images].empty?
              params[:event_images].each do |image|
                @event.images << Image.create(file: image, user: current_user)
              end
            end
            format.html { redirect_to event_invitees_path(@event) }
          else
            format.html { render :new }
            format.json { render json: @event.errors, status: :unprocessable_entity}
          end
        else
          format.html { render :new }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])

    if @event.update(event_params)
      if !params[:event_images].nil? && !params[:event_images].empty?
        params[:event_images].each do |image|
          @event.images << Image.create(file: image, user: current_user)
        end
      end
      respond_to do |format|
        format.html { redirect_to event_invitees_path(@event) }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def images
    @image = Image.find(params[:id])
    if params[:style] == 'original'
      image_path = @image.file.path
    elsif params[:style] == 'thumb'
      image_path = @image.file.path(:thumb)
    end
    send_file(image_path, filename: File.basename(@image.file_file_name, File.extname(@image.file_file_name)),
              type: @image.file_content_type, disposition: :inline)
  end

  def invitation
    @event = Event.find(params[:id])
    if params[:style] == 'original'
      image_path = @event.invitation.path
    elsif params[:style] == 'thumb'
      image_path = @event.invitation.path(:thumb)
    end
    send_file(image_path, filename: File.basename(@event.invitation_file_name, File.extname(@event.invitation_file_name)),
              type: @event.invitation_content_type, disposition: :inline)
  end

  def show
    @event = Event.find(params[:id])
    session[:event_id] = @event.id
    if current_user.has_role?("invitee")
      @invitee = Invitee.find_by_email(current_user.email)
      @numbers = []
      0.upto(@invitee.number) do |number|
        @numbers << number
      end
      @qrcode = RQRCode::QRCode.new("http://192.168.1.4:3000#{ update_arrival_invitee_path(@invitee) }")
      # @qrcode_png = @qrcode.to_img
      # @qrcode_png.resize(90, 90).save("public/qrcode_#{ @invitee.id }.png")
      @qrcode_png = @qrcode.to_img.resize(90, 90)
    elsif current_user.has_role?("admin")
      @ceremonial_response = Invitee.ceremonial_ok
      @reception_response = Invitee.reception_ok
    end
  end

  # show all receptionist for event
  def receptionist
    @event = Event.find(params[:event_id])
    @users = User.joins(:user_roles).where("user_roles.role_id": Role.find_by_name('receptionist'),
                                           "user_roles.event_id": @event)
  end

  def receptionist_new
    @event = Event.find(params[:event_id])
    @user = User.new
  end

  def receptionist_create
    @event = Event.find(params[:event_id])
    @user = User.new(user_params)
    @user.password_confirmation = @user.password
    # if @user.save
    @event.user_roles.create(role: Role.find_by_name("receptionist"), user: @user)
    redirect_to event_receptionist_path(@event)
  end

  def authorize
    # NOTE: Assumes the user is already authenticated to the app
    #user_id = request.session['user_id']
    logger.debug "------------------------request: #{request.inspect}"
    logger.debug "------------------------request.session: #{request.session.inspect}"
    credentials = authorizer.get_credentials("default", request)
    logger.debug "------------------------credentials: #{credentials.inspect}"
    if credentials.nil?
      redirect authorizer.get_authorization_url(login_hint: user_id, request: request)
    end
    # Credentials are valid, can call APIs
    # ...
  end

  def oauth2callback
    client_secrets = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_PATH)
    auth_client = client_secrets.to_authorization
    auth_client.update!(
      :scope => SCOPE,
      :redirect_uri => 'http://localhost:3000/oauth2callback')
    if request['code'] == nil
      auth_uri = auth_client.authorization_uri.to_s
      logger.debug "----------------------------auth_uri: #{auth_uri}"
      redirect_to(auth_uri)
    else
      auth_client.code = request['code']
      auth_client.fetch_access_token!
      # auth_client.client_secret = nil
      logger.debug "----------------------------auth_client: #{auth_client.inspect}"
      session[:credentials] = auth_client.to_json
      if session[:event]
        event = Event.new(session[:event])
        if event.save
          respond_to do |format|
            if insert_event(event) == 1
              format.html { redirect_to event_invitees_path(event) }
            else
              format.html { render :new }
              format.json { render json: event.errors, status: :unprocessable_entity}
            end
          end
        end
        # redirect_to controller: "events", actions: "create"
      else
        redirect_to('/')
      end
    end
=begin
    target_url = Google::Auth::WebUserAuthorizer.handle_auth_callback_deferred(request)
    logger.debug "----------------------target_url: #{target_url}"
    redirect_to target_url
=end
=begin
    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: "#{Dir.home}/.credentials/calendar-ruby-quickstart.json")
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    logger.debug "---------------------------current_user: #{current_user.inspect}"
    logger.debug "---------------------------session[user_id]: #{session['user_id']}"
    #credentials = authorizer.get_credentials(req.session['user_id'])
    credentials = authorizer.get_credentials(current_user.id)
    logger.debug "---------------------------credentials: #{credentials.inspect}"
    #auth_client = client_secrets.to_authorization
    logger.debug "-----------------oauth2callback: #{oauth2callback_path}"
    auth_client.update!(
      :scope => SCOPE,
      :redirect_uri => "http://localhost:3000#{oauth2callback_path}")
    if request['code'] == nil
      auth_uri = auth_client.authorization_uri.to_s
      redirect_to(auth_uri)
    else
      logger.debug "----------------request code: #{request['code']}"
      auth_client.code = request['code']
      auth_client.fetch_access_token!
      auth_client.client_secret = nil
      session[:credentials] = auth_client.to_json
      redirect_to('/events')
    end
=end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      event_param = params.require(:event).permit(:name, :description, :ceremonial_location_name, :ceremonial_location_address,
                                                  :ceremonial_start, :ceremonial_end, :reception_location_name,
                                                  :reception_location_address, :reception_start, :reception_end, :user_id, :invitation,
                                                  :global_password)
      change_to_wib(event_param)
    end

    def user_params
      params.require(:user).permit(:email, :password)
    end

    def setgoogleauth
      client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
      #token_store = Google::Auth::Stores::FileTokenStore.new(file: "#{Dir.home}/.credentials/calendar-ruby-quickstart.json")
      token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new(password: '0xdeadbeef'))
      logger.debug "---------------------------token_store: #{token_store.inspect}"
      authorizer = Google::Auth::WebUserAuthorizer.new(client_id, SCOPE, token_store, '/oauth2callback')
      logger.debug "---------------------------authorizer: #{authorizer.inspect}"
    end

    ##
    # Ensure valid credentials, either by restoring from the saved credentials
    # files or intitiating an OAuth2 authorization request via InstalledAppFlow.
    # If authorization is required, the user's default browser will be launched
    # to approve the request.
    #
    # @return [Signet::OAuth2::Client] OAuth2 credentials
    def authorize
      FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

=begin
      file_store = Google::APIClient::FileStore.new(CREDENTIALS_PATH)
      storage = Google::APIClient::Storage.new(file_store)
      auth = storage.authorize

      if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
        app_info = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_PATH)
        flow = Google::APIClient::InstalledAppFlow.new({
          :client_id => app_info.client_id,
          :client_secret => app_info.client_secret,
          :scope => SCOPE})
        auth = flow.authorize(storage)
        puts "Credentials saved to #{CREDENTIALS_PATH}" unless auth.nil?
      end
      auth
=end
      client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
      authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store) # Invalid Grant => Code already redeemed
      #authorizer = Google::Auth::WebUserAuthorizer.new(client_id, SCOPE, token_store, '/oauth2callback')
      user_id = 'default'
      credentials = authorizer.get_credentials(user_id, request)
      if credentials.nil?
        #url = authorizer.get_authorization_url(base_url: OOB_URI, request: request)
        url = authorizer.get_authorization_url(base_url: OOB_URI)
        puts "Open the following URL in the browser and enter the " +
             "resulting code after authorization"
        puts url
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(user_id: user_id, code: code, base_url: OOB_URI)
      end
      puts "credentials: #{credentials.inspect}"
      credentials
    end

    def change_to_wib(event_param)
      start_time = event_param[:ceremonial_start].to_datetime
      event_param[:ceremonial_start] = DateTime.new(start_time.year, start_time.month, start_time.day,
                                         start_time.hour, start_time.minute, start_time.second, '+7')
      end_time = event_param[:ceremonial_end].to_datetime
      event_param[:ceremonial_end] = DateTime.new(end_time.year, end_time.month, end_time.day,
                                       end_time.hour, end_time.minute, end_time.second, '+7')

      start_time = event_param[:reception_start].to_datetime
      event_param[:reception_start] = DateTime.new(start_time.year, start_time.month, start_time.day,
                                         start_time.hour, start_time.minute, start_time.second, '+7')
      end_time = event_param[:reception_end].to_datetime
      event_param[:reception_end] = DateTime.new(end_time.year, end_time.month, end_time.day,
                                       end_time.hour, end_time.minute, end_time.second, '+7')
      event_param
    end

    def insert_event(event)
      client_opts = JSON.parse(session[:credentials])
      auth_client = Signet::OAuth2::Client.new(client_opts)
      client = Google::Apis::CalendarV3::CalendarService.new
      client.authorization = auth_client
      new_event = Google::Apis::CalendarV3::Event.new({
        summary: event.name,
        description: event.description,
        location: "#{ event.reception_location_name } #{ event.reception_location_address }",
        start: { date_time: event.reception_start.to_datetime,
                 time_zone: 'Asia/Bangkok' },
        end: { date_time: event.reception_end.to_datetime,
               time_zone: 'Asia/Bangkok' },
        attendees: [],
        guestsCanInviteOthers: false,
        guestsCanSeeOtherGuests: false
      })

      if result = client.insert_event('primary', new_event, send_notifications: true)
        event.event_id = result.id
        event.save
        current_user.user_roles.create(event: event, role: Role.find_by_name('admin'))
        session.delete(:event)
        1
      else
        0
      end
    end
end
