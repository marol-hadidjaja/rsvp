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
#require 'multi_json'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'
CLIENT_SECRETS_PATH = 'client_id-quickstart.json'
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

  def index
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
  end

  def new
    @event = Event.new
  end

  def create
    unless session.has_key?(:credentials)
      redirect_to('/oauth2callback')
    else
      @event = Event.new(event_params)
      #@event.start = @event.end = DateTime.now
      @event.start = @event.end = DateTime.new(2016, 10, 8, 8, 0, 0, '+7')
      @event.user_id = current_user.id

      respond_to do |format|
        if @event.save
          #client = Google::APIClient.new(:application_name => APPLICATION_NAME)
          client_opts = JSON.parse(session[:credentials])
          auth_client = Signet::OAuth2::Client.new(client_opts)
          client = Google::Apis::CalendarV3::CalendarService.new
          client.authorization = auth_client
          #client.authorization = authorize
          #calendar_api = client.discovered_api('calendar', 'v3')
          @new_event = Google::Apis::CalendarV3::Event.new({
            summary: @event.name,
            description: @event.description,
            location: @event.location,
            start: { date_time: @event.start.to_datetime,
                     time_zone: 'Asia/Bangkok' },
                     end: { date_time: @event.end.to_datetime,
                   time_zone: 'Asia/Bangkok' },
            guestsCanInviteOthers: false
          })
          # @event.end.to_datetime.rfc3339,

          logger.debug "------------------------------------#{@new_event.inspect}"
          #logger.debug "------------------------------------start: #{@new_event.start['dateTime'].class.name}"
          #logger.debug "------------------------------------end: #{@new_event.end['dateTime'].class.name}"
=begin
          if @g_event = client.execute(:api_method => calendar_api.events.insert,
                                        :parameters => { 'calendarId' => 'primary', 'sendNotifications' => true },
                                        :body => JSON.dump(@new_event),
                                        :headers => { 'Content-Type' => 'application/json' })
            logger.debug "------------------------#{ @g_event.body }"
            format.html { redirect_to invitees_path }
          end
=end
          if result = client.insert_event('primary', @new_event, send_notifications: true)
            logger.debug "--------------------------#{result.inspect}"
            format.html { redirect_to invitees_path }
          end
        else
          format.html { render :new }
          format.json { render json: @invitee.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def edit
  end

  def update
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
      auth_client.client_secret = nil
      logger.debug "----------------------------auth_client: #{auth_client.inspect}"
      session[:credentials] = auth_client.to_json
      redirect_to('/events')
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
      params.require(:event).permit(:name, :description, :location)
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
      puts "authorizer: #{authorizer.inspect}"
      credentials = authorizer.get_credentials(user_id, request)
      puts "credentials: #{credentials.inspect}"
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
end
