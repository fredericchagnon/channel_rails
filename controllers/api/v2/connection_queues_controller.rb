##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::ConnectionQueuesController < ApiController
  #
  #---------------------------------------------------------------------------
  #
  # POST /connection_queues.json
  def create
    ConnectionQueue.add(@current_user, params[:connection_queue][:email])
    render :nothing => true, :status => :ok
  end

end