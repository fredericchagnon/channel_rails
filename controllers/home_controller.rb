##############################################################################
#                                                                            #
#                    COPYRIGHT 2011 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class HomeController < ApplicationController

  # # Must be loged-in to do anything here, except for accessing the index 
  # # which is the default public home page
  # # before_filter :authenticate_user!, :except =>[:index]
  # skip_before_filter :adjust_format_for_iphone

  def index
    response.headers['Cache-Control'] = 'public, max-age=300'
    # redirect_to root_path if user_signed_in?
  end

end
