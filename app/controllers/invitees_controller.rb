require 'csv'

class InviteesController < ApplicationController
  before_action :set_invitee, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, :except => [:update_coming]

  # GET /invitees
  # GET /invitees.json
  def index
    @invitees = Invitee.all
  end

  # GET /invitees/1
  # GET /invitees/1.json
  def show
  end

  # GET /invitees/new
  def new
    @invitee = Invitee.new
  end

  # GET /invitees/1/edit
  def edit
  end

  # POST /invitees
  # POST /invitees.json
  # TODO check
  def create
    @invitee = Invitee.new(invitee_params)

    respond_to do |format|
      if @invitee.save
        @users = User.where(email: invitee_params['email'])
        # create user for login and retrieve invitation
        if @users.empty?
          @user = User.create(email: invitee_params['email'], password: '12345678', password_confirmation: '12345678')
          logger.debug "-------------------------------------error : #{ @user.errors.inspect }"
        end
        format.html { redirect_to @invitee, notice: 'Invitee was successfully created.' }
        format.json { render :show, status: :created, location: @invitee }
      else
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
        if @user.update_attributes({ email: invitee_params.email })
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
    respond_to do |format|
      format.html { redirect_to invitees_url, notice: 'Invitee was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import_form
    respond_to do |format|
      format.html { render :import_form }
    end
  end

  def import
    @errors = []
    @success_count = 0
    CSV.foreach(params[:invitees].tempfile,
                :headers => true,
                :converters => :all,
                :header_converters => lambda { |h| h.downcase.gsub(' ', '_')}) do |row|
      new_row = row.to_hash
      #@invitee = Invitee.where(email: new_row[:email]).first_or_create
      @invitees = Invitee.where(email: new_row[:email])
      unless @invitees.empty?
        logger.debug "--------------------------find record"
        @invitee = @invitees.first
        if @invitee.update_attributes(new_row)
          @success_count += 1
        else
          @errors << { :name => new_row['name'], :errors => @invitee.errors }
        end
      else
        @invitee = Invitee.new(new_row)
        #@invitee.attributes = new_row
        if @invitee.save
          @success_count += 1
        else
          @errors << { :name => new_row['name'], :errors => @invitee.errors }
        end
      end # close check @invitee is new record

      @users = User.where(email: new_row['email'])
      # create user for login and retrieve invitation
      if @users.empty?
        logger.debug "-------------------------------------not find user #{ new_row.inspect }"
        @user = User.create(email: new_row['email'], password: '12345678', password_confirmation: '12345678')
        logger.debug "-------------------------------------error : #{ @user.errors.inspect }"
      end
    end

    respond_to do |format|
      format.html { render :import_form, :locals => { :message => 'message' } }
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
    @qr = RQRCode::QRCode.new("http://192.168.1.8:3000/invitees/#{ @invitation.id }/update_coming", :size => 20, :level => :h)
    respond_to do |format|
      format.html { render :invitation }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invitee
      @invitee = Invitee.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invitee_params
      params.require(:invitee).permit(:name, :relation, :number, :email, :address, :phone, :response, :arrival, :created_at, :updated_at)
    end
end
