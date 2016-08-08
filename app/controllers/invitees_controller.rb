require 'csv'
require 'roo'
require 'google/api_client/client_secrets'
require 'google/apis/calendar_v3'
require 'googleauth'
#require 'googleauth/web_user_authorizer'
#require 'googleauth/stores/redis_token_store'

class InviteesController < ApplicationController
  before_action :set_invitee, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, :except => [:update_coming]
  before_action :set_event, only: [:index, :new, :create]

  # GET /invitees
  # GET /invitees.json
  def index
    if current_user.user_roles.empty?
      if Event.where(user_id: current_user.id).empty?
        redirect_to new_event_path
      else
        @invitees = Invitee.all
      end
    else
      @invitees = Event.find(params[:event_id]).invitees
    end
  end

  # GET /invitees/1
  # GET /invitees/1.json
  def show
  end

  # GET /invitees/new
  def new
    @invitee = Invitee.new(event_id: @event.id)
  end

  # GET /invitees/1/edit
  def edit
  end

  # POST /invitees
  # POST /invitees.json
  # TODO check
  def create
    @invitee = Invitee.new(invitee_params)

    if @invitee.save
      @users = User.where(email: invitee_params['email'])
      # create user for login and retrieve invitation
      if @users.empty?
        @user = User.create(email: invitee_params['email'], password: '12345678', password_confirmation: '12345678')
        @event.user_roles.create(role: Role.find_by_name("invitee"), user: @user)
        logger.debug "-------------------------------------error : #{ @user.errors.inspect }"
      else
        @user = @users.first
        @event.user_roles.create(role: Role.find_by_name("invitee"), user: @user)
      end

      unless session.has_key?(:credentials)
        session[:new_attendees] = { email: invitee_params['email'] }
        redirect_to oauth2callback_path
      else
        client_opts = JSON.parse(session[:credentials])
        auth_client = Signet::OAuth2::Client.new(client_opts)
        client = Google::Apis::CalendarV3::CalendarService.new
        client.authorization = auth_client

        g_event = client.get_event('primary', @event.event_id)
        # attendees = [ { email: 'a@b.com' } ]
        if session[:new_attendees]
          attendees = session[:new_attendees]
          session.delete(:new_attendees)
        else
          attendees = { email: invitee_params['email'] }
        end
        g_event.attendees = [] if g_event.attendees.nil?
        g_event.attendees.push(attendees)

        result = client.update_event('primary', g_event.id, g_event)#, send_notifications: true)
        InviteeMailer.invitation_email(@event, @invitee).deliver
      end

      respond_to do |format|
        #format.html { render :show, status: :created, location: @invitee}
        format.html { redirect_to @invitee, notice: 'Invitee was successfully created.' }
        format.json { render :show, status: :created, location: @invitee }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @invitee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invitees/1
  # PATCH/PUT /invitees/1.json
  # TODO check
  def update
    prev_email = @invitee.email
    respond_to do |format|
      if @invitee.update(invitee_params)
        @user = User.find_by_email(prev_email)
        if @user.update_attributes({ email: invitee_params[:email] })
          format.html { redirect_to @invitee, notice: 'Invitee was successfully updated.' }
          format.json { render :show, status: :ok, location: @invitee }
        end
      else
        format.html { render :edit }
        format.json { render json: @invitee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invitees/1
  # DELETE /invitees/1.json
  def destroy
    @invitee.destroy
    unless session.has_key?(:credentials)
      session[:delete_attendees] = { email: @invitee.email }
      redirect_to oauth2callback_path
    else
      @event = Event.find(@invitee.event)
      client_opts = JSON.parse(session[:credentials])
      auth_client = Signet::OAuth2::Client.new(client_opts)
      client = Google::Apis::CalendarV3::CalendarService.new
      client.authorization = auth_client

      g_event = client.get_event('primary', @event.event_id)
      # attendees = [ { email: 'a@b.com' } ]
      if session[:delete_attendees]
        attendees = session[:delete_attendees]
        session.delete(:delete_attendees)
      else
        attendees = { email: @invitee.email }
      end
      g_event.attendees.delete_if{ |attendee| attendee.email == attendees[:email] }

      result = client.update_event('primary', g_event.id, g_event, send_notifications: true)
      respond_to do |format|
        format.html { redirect_to event_invitees_url(@invitee.event), notice: 'Invitee was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  def import_form
    @event = Event.find(params[:event_id])
    respond_to do |format|
      format.html { render :import_form }
    end
  end

  def import
    @event = Event.find(params[:event_id])
    @result_import = { errors: [], success: [] }
    unless session.has_key?(:credentials)
      redirect_to('/oauth2callback')
    else
      spreadsheet = open_spreadsheet(params[:invitees])
      spreadsheet.sheets.each do |sheet| # looping all sheet
        spreadsheet.default_sheet = "#{sheet}" # picking current sheet as default to be processing
        header = spreadsheet.row(1).map{ |h| h.downcase }
        header_mapping = { 'nama': 'name',
                           'email': 'email',
                           'relasi': 'relation',
                           'jumlah': 'number',
                           'alamat': 'address',
                           'telepon': 'phone' }
        new_header = header.map{ |h| header_mapping[h.to_sym] }
        (2..spreadsheet.last_row).each do |i| # looping all excel data
          row = Hash[[new_header, spreadsheet.row(i)].transpose]
          # member = Member.find_by_id_card_number(row["id_card_number"]) || Member.new(row.reject{ |k, r| k.nil? })
          row["event_id"] = @event.id
          invitee = Invitee.find_by_email(row["email"]) || Invitee.new(row.reject{ |k, r| k.nil? })
          invitee.attributes = row.reject{ |k, r| k == "email" || k.nil? } unless invitee.new_record?
          unless invitee.save
            @result_import[:errors] << { email: row['email'], errors: invitee.errors.messages }
          else
            @result_import[:success] << { email: row['email'] }
            @users = User.where(email: row['email'])
            # create user for login and retrieve invitation
            if @users.empty?
              logger.debug "-------------------------------------not find user #{ row.inspect }"
              @user = User.create(email: row['email'], password: '12345678', password_confirmation: '12345678')
              @event.user_roles.create(role: Role.find_by_name("invitee"), user: @user)
              logger.debug "-------------------------------------error : #{ @user.errors.inspect }"
            else
              @user = @users.first
              @event.user_roles.create(role: Role.find_by_name("invitee"), user: @user)
            end
          end
        end # looping all excel data
      end # looping all sheets

      client_opts = JSON.parse(session[:credentials])
      auth_client = Signet::OAuth2::Client.new(client_opts)
      client = Google::Apis::CalendarV3::CalendarService.new
      client.authorization = auth_client

      g_event = client.get_event('primary', @event.event_id)
      g_event.attendees = @result_import[:success]

      result = client.update_event('primary', g_event.id, g_event, send_notifications: true)
      print result.updated

      respond_to do |format|
        format.html { render :import_form }
      end
    end
  end

  def export
    @invitees = Invitee.all

    respond_to do |format|
      format.csv { send_data @invitees.to_csv, filename: "invitees-#{Date.today}.csv" }
    end
  end

  def send_invitation
    InviteeMailer.invitation_email.deliver
  end

  def invitation
    @invitation = Invitee.find_by_email(current_user.email)
    #@qr = RQRCode::QRCode.new( 'https://github.com/whomwah/rqrcode', :size => 4, :level => :h )
    unless @invitation.nil?
      @qr = RQRCode::QRCode.new("http://192.168.1.8:3000/invitees/#{ @invitation.id }/update_coming", :size => 20, :level => :h)
      respond_to do |format|
        format.html { render :invitation }
      end
    else
      "Invitation not found"
    end
  end

  def update_coming
    @invitee = Invitee.find(params[:id])
    respond_to do |format|
      format.json { render json: @invitee, status: :unprocessable_entity }
    end
  end

  def update_rsvp

  end

  def calendars
    client = Signet::OAuth2::Client.new(access_token: session[:access_token])

    service = Google::Apis::CalendarV3::CalendarService.new

    service.authorization = client

    @calendar_list = service.list_calendar_lists
  end

  def update_rsvp_redirect
    client = Signet::OAuth2::Client.new({
      client_id: "598369950071-lo782826gopcb8bmm91no7d0d75poqu2.apps.googleusercontent.com",
      client_secret: "uKZQkjK7mDIFdgK0r0q4AMxv",
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY,
      redirect_uri: update_path
    })

    redirect_to client.authorization_uri.to_s
  end

  def oauth2callback
    client = Signet::OAuth2::Client.new({
      client_id: "598369950071-lo782826gopcb8bmm91no7d0d75poqu2.apps.googleusercontent.com",
      client_secret: "uKZQkjK7mDIFdgK0r0q4AMxv",
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      redirect_uri: url_for(:action => :callback),
      code: params[:code]
    })

    response = client.fetch_access_token!

    session[:access_token] = response['access_token']

    redirect_to url_for(:action => :calendars)
  end

  # suggest all relations that have been created
  def relations
    relations = Invitee.all.map(&:relation).uniq
    relations_h = []
    relations.each do |relation|
      relations_h.push({ item: relation, text: relation })
    end
    render json: { items: relations_h }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invitee
      @invitee = Invitee.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invitee_params
      params.require(:invitee)
        .permit(:event_id, :name, :relation, :number, :email, :address, :phone, :response, :arrival)
    end

    def set_event
      @event = Event.find(params[:event_id])
    end

    def update_google_event(attendees)
      unless session.has_key?(:credentials)
        redirect_to oauth2callback_path
      else
        client_opts = JSON.parse(session[:credentials])
        auth_client = Signet::OAuth2::Client.new(client_opts)
        client = Google::Apis::CalendarV3::CalendarService.new
        client.authorization = auth_client

        g_event = client.get_event('primary', @event.event_id)
        # attendees = [ { email: 'a@b.com' } ]
        g_event.attendees = attendees

        result = client.update_event('primary', g_event.id, g_event, send_notifications: true)
      end
    end

    def open_spreadsheet(file)
      case File.extname(file.original_filename)
      when '.csv' then Roo::CSV.new(file.path)
      when '.xls' then Roo::Excel.new(file.path)
      when '.xlsx' then Roo::Excelx.new(file.path)
      else raise "Unknown file type: #{file.original_filename}"
      end
    end
end
