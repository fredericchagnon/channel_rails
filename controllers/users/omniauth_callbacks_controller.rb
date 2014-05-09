##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
# Controller that handles all the OmniAuth callbacks (named by providers)
#
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  #
  skip_before_filter :verify_authenticity_token, :only => [:google]
  #
  #---------------- METHOD THAT HANDLES FACEBOOK CALLBACK --------------------
  #
  def facebook
    # Get a handle on the exsiting user or create a new one depending on hash
    # returned by callback
    @user = User.oauthicate(request.env["omniauth.auth"], current_user)
    # Check to see that the user instance returned is persisted in the DB
    if @user.persisted?
      respond_to do |format|
        format.html {
          render :json => {:token => request.env["omniauth.auth"]['credentials']['token'], :email => @user.email}, :status => :ok
        }
      end
    # If the user isn't persisted in the DB -> then clear the session data and
    # return to the user registration page
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      render :nothing => true, :status => :bad_request
      # redirect_to new_user_registration_url
    end
  end
  #
  #---------------- METHOD THAT HANDLES GOOGLE CALLBACK ----------------------
  #
  def google
    # Get a handle on the exsiting user or create a new one depending on hash
    # returned by callback
    @user = User.oauthicate(request.env["omniauth.auth"], current_user)
    # Check to see that the user instance returned is persisted in the DB
    if @user.persisted?
      respond_to do |format|
        format.html {
          render :json => {:token => @user.authenticators.where(:service => "google").last.token, :email => @user.email}, :status => :ok
        }
      end
    # If the user isn't persisted in the DB -> then clear the session data and
    # return to the user registration page
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      render :nothing => true, :status => :bad_request
      # redirect_to new_user_registration_url
    end
  end
  #
  #---------------------------------------------------------------------------
  #
  def passthru
    logger.error "request env is #{request.env['omniauth.auth']}"
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
  #
  #---------------------------------------------------------------------------
  #
end
