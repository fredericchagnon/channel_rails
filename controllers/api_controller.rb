##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class ApiController < ApplicationController
  #
  #---------------------------------------------------------------------------
  #
  # Authenticate all API calls unless they are explicitly "skipped"
  before_filter :authenticate_api_calls
  # Skip the CSRF Meta Tag check for all API calls
  skip_before_filter :verify_authenticity_token 
  #
  #---------------------------------------------------------------------------
  #
  # All API calls (all functions in controllers that inherit this one) respond
  # only to JSON format
  respond_to :json
  #
  #---------------------------------------------------------------------------
  #
  protected
  #
  #---------------------------------------------------------------------------
  #
  def authenticate_api_calls
    # Authenticate the API call
    user = User.authenticate_api_call(params[:user][:id], params[:user][:authentication_token], params[:user][:device][:unique_identifier])
    if user.class == User
      @current_user = user
    else
      render :nothing => true, :status => user
    end
  end
  #
  #---------------------------------------------------------------------------
  #
  # Custom responder to make sure that calling client gets the appropriate
  # information back depending on who was the last caller
  def custom_responder(object)
    if @current_user.last_api_device_id == params[:user][:device][:unique_identifier]
      respond_with(object)
    else
      @current_user.update_attribute(:last_api_device_id, params[:user][:device][:unique_identifier])
      render "api/v2/users/show"
    end
  end
  #
  #---------------------------------------------------------------------------
  #
end
