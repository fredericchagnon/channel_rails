##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::ConnectionsController < ApiController
  require 'ostruct'
  #
  #---------------------------------------------------------------------------
  #
  before_filter :find_connection, :only => [:show, :update, :destroy]
  before_filter :modify_params_hash,  :only => [:update]
  #
  #---------------------------------------------------------------------------
  #
  # GET /connections.json
  def index
    @cntcts = []
    Connection.from_or_to(@current_user).active.each do |x|
      @cntcts << x.contact(@current_user)
    end
    respond_with(@cntcts)
  end

  # GET /connections/:id.json
  def show
    respond_with(@cntct = @conn.contact(@current_user))
  end

  # PUT /connections/:id.json
  def update
    @conn.update_attributes(@newhash)
    if @conn.save
      respond_with(@cntct = @conn.contact(@current_user))
    else
      render :nothing => true, :status => :bad_request
    end
  end

  # DELETE /connections/:id.json
  def destroy
    @conn.disconnect(@current_user)
    respond_with(@conn)
  end

  protected

  def find_connection
    @conn = Connection.from_or_to(@current_user).active.find(params[:connection][:id])
    render :nothing => true, :status => :bad_request if @conn.nil?
  end

  def modify_params_hash
    # Modify the incoming request params hash (change one key name)
    if @conn.from == @current_user
      mappings = {"persona_ids" => "from_persona_ids"}
    elsif @conn.to == @current_user
      mappings = {"persona_ids" => "to_persona_ids"}
    else
      render :nothing => true, :status => :bad_request
    end
    params[:connection].keep_if { |k,v| k.to_sym == :persona_ids }
    @newhash = Hash[params[:connection].map { |k,v| [mappings[k]||k,v]}]
  end

end