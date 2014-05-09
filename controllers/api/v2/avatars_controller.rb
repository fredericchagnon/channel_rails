##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::AvatarsController < ApiController
  require 'open-uri'
  #
  #---------------------------------------------------------------------------
  #
  skip_before_filter :authenticate_api_calls, :only => [:create]
  skip_after_filter :set_last_api_caller_device, :only => [:create]
  before_filter :find_user, :find_persona, :only => [:show]
  before_filter :authenticate_avatar_call, :get_persona, :only => [:create]
  #
  #---------------------------------------------------------------------------
  #
  # GET /avatars/:id.json
  def show
    begin
      # avatar = File.open(@persona.avatar.asset_url)
      avatar = open(@persona.avatar.asset_url)
      send_data avatar.read, :disposition => 'inline'
      # avatar = Mongo::GridFileSystem.new(Mongoid.database).open(@persona.avatar.asset.to_s[8..@persona.avatar.asset.to_s.length], 'r')
      # send_data avatar.read, :disposition => 'inline'
      # # send_file @persona.avatar.asset.to_s[8..@persona.avatar.asset.to_s.length]
      # # if params[:avatar_user][:persona][:avatar_type] == "contact_list"
      # #   avatar = Mongo::GridFileSystem.new(Mongoid.database).open("uploads/contact_#{@persona.id.to_s}.jpg", 'r')
      # # elsif params[:avatar_user][:persona][:avatar_type] == "contact_view"
      # #   avatar = Mongo::GridFileSystem.new(Mongoid.database).open("uploads/#{@persona.id.to_s}.jpg", 'r')
      # # end
      # # send_data avatar.read, :disposition => 'inline'
    rescue
      render :nothing => true, :status => :not_found
    end
  end

  # POST /avatars.json
  def create
    img = Avatar.new(:filename => "#{@persona.id.to_s}")
    @persona.avatar = img
    @persona.avatar.asset = params[:file]
    if @persona.save
      render :json => "{id: #{img.id}}", :status => :ok
    else
      render :nothing => true, :status => :unprocessable_entity
    end
  end

  protected

  def authenticate_avatar_call
    user = User.authenticate_api_call(params[:user_id], params[:authentication_token], params[:device_id])
    if user.class == User
      @current_user = user
    else
      render :nothing => true, :status => user
    end
  end

  def find_user
    @user = User.find(params[:avatar_user][:id])
    render :nothing => true, :status => :bad_request if @user.nil?
  end

  def find_persona
    @persona = @user.personas.find(params[:avatar_user][:persona][:id])
    render :nothing => true, :status => :bad_request if @persona.nil?
  end

  def get_persona
    @persona = @current_user.personas.find(params[:persona_id])
    render :nothing => true, :status => :bad_request if @persona.nil?
  end

end