##############################################################################
#                                                                            #
#                    COPYRIGHT 2011 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class ApplicationController < ActionController::Base
  #
  #---------------------------------------------------------------------------
  #
  protect_from_forgery
  #
  # Do not store password in log files
  # filter_parameter_logging :password
  #
  # Must be loged-in to do anything here, except for accessing the index 
  # which is the default public home page
  # before_filter :authenticate_user!
  #
  # # Set iPhone format when appropriate
  # # before_filter :adjust_format_for_iphone
  # before_filter :adjust_format_for_app
  # #
  # # Define helper method to detect whether iPhone mobile safari is browser
  # # helper_method :iphone_user_agent?
  # # Define helper method to detect whether browser from within app
  # # helper_method :app_user_agent?
  #
  # After filter to update the last device that made a changing API call
  after_filter :set_last_api_caller_device
  #
  #---------------------------------------------------------------------------
  #
  protected
  #
  #---------------------------------------------------------------------------
  #
  def set_last_api_caller_device
    # Only do this if the request is a PUT, POST or DELETE
    unless request.env["REQUEST_METHOD"] == "GET"
      # for an API call
      if @current_user.nil? == false
        @current_user.update_attribute(:last_api_device_id, params[:user][:device][:unique_identifier])
      # for a webapp call
      elsif current_user.nil? == false
        current_user.update_attribute(:last_api_device_id, "webapp")
      end
    end
  end
  # #
  # #---------------------------------------------------------------------------
  # #
  # # Method that adjusts the rendered format for iPhone: 2 strategies possible:
  # # make a subdomain for iPhones (commented out) or detect incoming request
  # # and adjust accordinly (strategy selected here)
  # #
  # # These methods are taken from Advanced Rails Recipes by Mike Clark (2011)
  # # Recipe #21 "Support an iPhone Interface" by Ben Smith
  # #
  # def adjust_format_for_iphone
  #   # iPhone sub-domain request
  #   # request.format = :iphone if iphone_subdomain?
  #   # Detect from iPhone user-agent
  #   request.format = :iphone if iphone_user_agent? 
  # end
  # #
  # def adjust_format_for_app
  #   # iPhone sub-domain request
  #   # request.format = :app if app_subdomain?
  #   # Detect from iPhone user-agent
  #   request.format = :app if app_user_agent? 
  # end
  # #
  # #---------------------------------------------------------------------------
  # #
  # # Request from an iPhone or iPod touch? # (Mobile Safari user agent)
  # def iphone_user_agent?
  #   request.env["HTTP_USER_AGENT"] &&
  #   request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  # end
  # #
  # # Request from app
  # def app_user_agent?
  #   request.env["HTTP_USER_AGENT"] &&
  #   request.env["HTTP_USER_AGENT"][/(Mobile)/] &&
  #   request.env["HTTP_USER_AGENT"][/(Mozilla)/]
  # end
  # #
  # #---------------------------------------------------------------------------
  # #
  # # def iphone_subdomain?
  # #   return request.subdomains.first == "iphone"
  # # end
  # # #
  # # def app_subdomain?
  # #   return request.subdomains.first == "app"
  # # end
  # #
  # #---------------------------------------------------------------------------
  # #
end
