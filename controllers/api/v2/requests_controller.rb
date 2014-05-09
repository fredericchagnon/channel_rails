##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::RequestsController < ApiController
  #
  #---------------------------------------------------------------------------
  #
  before_filter :find_request, :only => [:update, :destroy]
  #
  #---------------------------------------------------------------------------
  #
  # POST /requests.json
  def create
    @conn_request = Connection.request({from_id: @current_user.id, to_id: params[:request][:user_id], from_persona_ids: params[:request][:persona_ids]})
    if @conn_request == :conflict
      render :nothing => true, :status => :conflict
    else
      respond_with(@conn_request)
    end
  end

  # PUT /requests/:id.json
  def update
    @conn_request.update_attributes({to_persona_ids: params[:request][:persona_ids], from_status: Connection::ACCEPTED, to_status: Connection::ACCEPTED})
    respond_with(@conn_request)
  end

  # DELETE /requests/:id.json
  def destroy
    @conn_request.update_attributes({to_status: Connection::REJECTED})
    respond_with(@conn_request)
  end

  protected

  def find_request
    @conn_request = Connection.to_user(@current_user).conn_pending.find(params[:request][:id])
    render :nothing => true, :status => :bad_request if @conn_request.nil?
  end

end