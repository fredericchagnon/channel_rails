##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::PasswordsController < ApiController
  #
  #---------------------------------------------------------------------------
  #
  skip_before_filter :authenticate_api_calls
  skip_after_filter :set_last_api_caller_device
  #
  #---------------------------------------------------------------------------
  #
  # GET /passwords.json
  def index
    @current_user = User.where(email: params[:user][:email].strip.downcase).first
    @current_user.send_reset_password_instructions unless @current_user.nil?
    render :nothing => true, :status => :ok
  end

end