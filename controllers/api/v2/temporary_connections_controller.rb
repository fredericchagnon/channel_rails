##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::TemporaryConnectionsController < ApiController
  #
  #---------------------------------------------------------------------------
  #
  # POST /temporary_connections.json
  def create
    @current_user.in_person(params[:temporary_connection])
    render :nothing => true, :status => :ok
  end

end