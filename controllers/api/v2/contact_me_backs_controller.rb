##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::ContactMeBacksController < ApiController
  #
  #---------------------------------------------------------------------------
  #
  before_filter :find_contact_me_back, :only => [:destroy]
  before_filter :ensure_connected, :only => [:create]
  #
  #---------------------------------------------------------------------------
  #
  # GET /contact_me_backs.json
  def index
    @contact_me_backs = ContactMeBack.to_owner(@current_user.id)
    respond_with(@contact_me_backs)
  end

  # POST /contact_me_backs.json
  def create
    @contact_me_back = ContactMeBack.request({from_id: @current_user.id, to_id: params[:contact_me_back][:user_id]})
    if @contact_me_back == false
      render :nothing => true, :status => :bad_request
    else
      respond_with(@contact_me_back)
    end
  end

  # DELETE /contact_me_backs/:id.json
  def destroy
    @contact_me_back.destroy
    respond_with(@contact_me_back)
  end

  protected

  def find_contact_me_back
    @contact_me_back = ContactMeBack.to_owner(@current_user.id).find(params[:contact_me_back][:id])
    render :nothing => true, :status => :bad_request if @contact_me_back.nil?
  end

  def ensure_connected
    u = User.find(params[:contact_me_back][:user_id])
    if u.nil?
      render :nothing => true, :status => :bad_request
    else
      c = Connection.connection(@current_user, u)
      if c.nil? or c.connected? == false
        render :nothing => true, :status => :bad_request
      end
    end
  end

end