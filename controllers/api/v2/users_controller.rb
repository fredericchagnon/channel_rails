##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::UsersController < ApiController
  #
  #---------------------------------------------------------------------------
  #
  before_filter :modify_params_hash,  :only => [:update]
  before_filter :find_user, :only => [:sign_in]
  before_filter :find_oath_user, :only => [:sign_in_oauth]
  skip_after_filter :set_last_api_caller_device, :only => [:destroy, :sign_in_oauth, :sign_out]
  skip_before_filter :authenticate_api_calls, :only => [:sign_in, :sign_up, :sign_in_oauth]
  #
  #---------------------------------------------------------------------------
  #
  # GET /users.json
  def index
    @users = User.search(params[:search_string])
    if @users.nil?
      render :nothing => true, :status => :not_found
    else
      respond_with(@users)
    end
  end

  # GET /users/:id.json
  def show
    custom_responder(@current_user)
  end

  # PUT /users/:id.json
  def update
    @current_user.update_attributes(@newhash)
    if @current_user.save
      custom_responder(@current_user)
    else
      render :nothing => true, :status => :bad_request
    end
  end

  # DELETE /users/:id.json
  def destroy
    @current_user.destroy
    respond_with(@current_user)
  end

  # POST users/sign_up.json
  def sign_up
    if User.where(email: params[:user][:email].strip.downcase).first.nil?
      @current_user = User.sign_up(params)
      unless @current_user.nil?
        respond_with(@current_user)
      else
        render :nothing => true, :status => :bad_request
      end
    else
      render :nothing => true, :status => :conflict
    end
  end

  # POST /users/sign_in.json
  def sign_in
    if @current_user.valid_password?(params[:user][:password])
      respond_with(@current_user) if @current_user.sign_in(params[:user][:device])
    else
      render :nothing => true, :status => :unauthorized
    end
  end

  # POST /users/sign_out.json
  def sign_out
    # Logout all devices or simply current device
    if params[:all_devices]
      @current_user.authentication_token = nil
      @current_user.devices.destroy_all
    else
      # Reset the auth token if this is the only device
      @current_user.authentication_token = nil if @current_user.devices.count == 1
      @current_user.devices.where(unique_identifier: params[:user][:device][:unique_identifier]).destroy_all
    end
    respond_with(@current_user.save)
  end

  # POST /users/sign_in_oauth.json
  def sign_in_oauth
    if @current_user.sign_in(params[:user][:device])
      respond_with(@current_user)
    else
      render :nothing => true, :status => :bad_request
    end
  end


  protected

  def modify_params_hash
    # Modify the incoming request params hash (change one key name)
    mappings = {"personas" => "personas_attributes", 
                "statuses" => "statuses_attributes",
                "contact_handles" => "contact_handles_attributes"}
    @newhash = Hash[params[:user].map { |k,v| [mappings[k]||k,v]}]
    @newhash.keep_if { |k,v| [:current_status, :personas_attributes, :statuses_attributes, :contact_handles_attributes].include?(k.to_sym) }
  end

  def find_user
    @current_user = User.where(email: params[:user][:email].strip.downcase).first
    render :nothing => true, :status => :not_found if @current_user.nil?
  end

  def find_oath_user
    @current_user = User.authenticate_oauth(params[:user])
    render :nothing => true, :status => :unauthorized if @current_user.nil?
  end

end