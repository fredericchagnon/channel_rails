##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::ContactHandlesController < ApiController
  #
  #---------------------------------------------------------------------------
  #
  before_filter :find_contact_handle, :only => [:show, :update, :destroy]
  before_filter :modify_create_params_hash,  :only => [:create]
  before_filter :modify_update_params_hash,  :only => [:create, :update]
  #
  #---------------------------------------------------------------------------
  #
  # GET /contact_handles.json
  def index
    custom_responder(@contact_handles = @current_user.contact_handles.all)
  end

  # GET /contact_handles/:id.json
  def show
    custom_responder(@contact_handle)
  end

  # POST /create.json
  def create
    @contact_handle = @current_user.contact_handles.build(@newhash, @type)
    if @contact_handle.valid? && @contact_handle.save
      custom_responder(@contact_handle)
    else
      @contact_handle.destroy
      render :nothing => true, :status => :bad_request
    end
  end

  # PUT /update.json
  def update
    @contact_handle.update_attributes(@newhash)
    custom_responder(@contact_handle)
  end

  # POST /import.json
  def import
    unless params[:user][:contact_handles].empty?
      @contact_handles = []
      mappings = {"protocols" => "protocols_attributes"}
      params[:user][:contact_handles].each do |c|
        newhash = Hash[c.map {|k,v| [mappings[k]||k,v]}]
        unless newhash.has_key?("public_flag")
    	    newhash["public_flag"] = @current_user.public_flag
        end
        if c[:url].nil? == false and ALL_URL_VALUES.collect{|x| x.downcase}.include?(c[:url].downcase)
          type = URLCLASS_MAP[c[:url].downcase].constantize
        else
          return
        end
        contact_handle = @current_user.contact_handles.build(newhash, type)
        if contact_handle.valid? && contact_handle.save
          @contact_handles << contact_handle
        else
          contact_handle.destroy
        end
      end
      # respond_with(@contact_handles)
      respond_with(@current_user)
    else
      render :nothing => true, :status => :bad_request
    end
  end

  # DELETE /delete.json
  def destroy
    @contact_handle.destroy
    custom_responder(@contact_handle)
  end

  protected

  def find_contact_handle
    @contact_handle = @current_user.contact_handles.find(params[:user][:contact_handle][:id])
    render :nothing => true, :status => :bad_request if @contact_handle.nil?
  end

  def modify_create_params_hash
    if params[:user][:contact_handle][:url].nil? == false and ALL_URL_VALUES.collect{|x| x.downcase}.include?(params[:user][:contact_handle][:url].downcase)
      @type = URLCLASS_MAP[params[:user][:contact_handle][:url].downcase].constantize
    else
      render :nothing => true, :status => :bad_request
    end
  end

  def modify_update_params_hash
    # Modify the incoming request params hash (change one key name)
    mappings = {"protocols" => "protocols_attributes"}
    @newhash = Hash[params[:user][:contact_handle].map { |k,v| [mappings[k]||k,v]}]
    # Make sure the public_flag is set according to the user's value
    unless @newhash.has_key?("public_flag")
	    @newhash["public_flag"] = @current_user.public_flag
    end
  end

end
