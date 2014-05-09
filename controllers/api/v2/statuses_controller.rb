##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::StatusesController < ApiController
  #
  #---------------------------------------------------------------------------
  #
  before_filter :find_status, :only => [:show, :update, :destroy]
  before_filter :modify_params_hash,  :only => [:create, :update]
  #
  #---------------------------------------------------------------------------
  #
  # GET /statuses.json
  def index
    custom_responder(@statuses = @current_user.statuses.all)
  end

  # GET /statuses/:id.json
  def show
    custom_responder(@status)
  end

  # POST /statuses.json
  def create
    @status = @current_user.statuses.build(@newhash)
    if @status.valid? && @status.save
      custom_responder(@status)
    else
      @status.destroy
      render :nothing => true, :status => :bad_request
    end
  end

  # PUT /statuses/:id.json
  def update
    @status.update_attributes(@newhash)
    custom_responder(@status)
  end

  # DELETE /statuses/:id.json
  def destroy
    @status.destroy
    custom_responder(@status)
  end

  protected

  def find_status
    @status = @current_user.statuses.find(params[:user][:status][:id])
    render :nothing => true, :status => :bad_request if @status.nil?
  end

  def modify_params_hash
    # Modify the incoming request params hash (change one key name)
    mappings = {"persona_handles" => "persona_handles_attributes"}
    @newhash = Hash[params[:user][:status].map { |k,v| [mappings[k]||k,v]}]
  end

end
