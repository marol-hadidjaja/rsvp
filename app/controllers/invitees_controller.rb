class InviteesController < ApplicationController
  before_action :set_invitee, only: [:show, :edit, :update, :destroy]

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
  def create
    @invitee = Invitee.new(invitee_params)

    respond_to do |format|
      if @invitee.save
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
  def update
    respond_to do |format|
      if @invitee.update(invitee_params)
        format.html { redirect_to @invitee, notice: 'Invitee was successfully updated.' }
        format.json { render :show, status: :ok, location: @invitee }
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
      @invitee = Invitee.where(email: new_row[:email]).first_or_create
      unless @invitee.new_record?
        logger.debug "--------------------------find record"
        if @invitee.update_attributes(new_row)
          @success_count += 1
        else
          binding.pry
          @errors << { :name => row.to_hash['name'], :errors => @invitee.errors }
        end
      else
        @invitee.attributes = new_row
        if @invitee.save
          @success_count += 1
        else
          @errors << { :name => row.to_hash['name'], :errors => @invitee.errors }
        end
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
