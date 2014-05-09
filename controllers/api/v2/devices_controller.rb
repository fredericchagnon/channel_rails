##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::DevicesController < ApiController
  #
  #---------------------------------------------------------------------------
  #
  before_filter :find_device, :only => [:update]
  #
  #---------------------------------------------------------------------------
  #
  # PUT /devices/:id.json
  def update
    @device.update_attributes(params[:user][:device])
    custom_responder(@device)
  end

  protected

  def find_device
    @device = @current_user.devices.where(unique_identifier: params[:user][:device][:unique_identifier]).first
    render :nothing => true, :status => :bad_request if @device.nil?
  end
end