##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::ImportCallbacksController < ApiController
  #
  #---------------------------------------------------------------------------
  #
  skip_before_filter :authenticate_api_calls, :only => [:google, :facebook]
  #
  #---------------- METHOD THAT HANDLES FACEBOOK CALLBACK --------------------
  #
  def facebook
    FacebookImportWorker.perform_async(params[:channel_token], params[:code])
    render :nothing => true, :status => :ok
  end
  #
  #---------------- METHOD THAT HANDLES GOOGLE CALLBACK ----------------------
  #
  def google
    GoogleImportWorker.perform_async(params[:channel_token], params[:token])
    render :nothing => true, :status => :ok
  end
  #
  #---------------------------------------------------------------------------
  #
end
