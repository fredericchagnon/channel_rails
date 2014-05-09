##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::SuggestsController < ApiController
  #
  #---------------------------------------------------------------------------
  #
  before_filter :find_suggest, :only => [:update, :destroy]
  before_filter :ensure_connected, :only => [:create]
  #
  #---------------------------------------------------------------------------
  #
  # POST /suggests.json
  def create
    @suggest = Connection.suggest({by_id: @current_user.id, from_id: params[:suggest][:from_id], to_id: params[:suggest][:to_id]})
    if @suggest == :conflict
      render :nothing => true, :status => :conflict
    else
      respond_with(@suggest)
    end
  end

  # PUT /suggests/:id.json
  def update
    if @suggest.to == @current_user
      @suggest.update_attributes({to_persona_ids: params[:suggest][:persona_ids], to_status: Connection::ACCEPTED})
    else
      @suggest.update_attributes({from_persona_ids: params[:suggest][:persona_ids], from_status: Connection::ACCEPTED})
    end
    respond_with(@suggest)
  end

  # DELETE /suggests/:id.json
  def destroy
    if @suggest.to == @current_user
      @suggest.update_attributes({to_status: Connection::REJECTED})
    else
      @suggest.update_attributes({from_status: Connection::REJECTED})
    end
    respond_with(@suggest)
  end

  protected

  def find_suggest
    @suggest = Connection.from_or_to(@current_user).find(params[:suggest][:id])
    if @suggest.nil?
      render :nothing => true, :status => :bad_request
    else
      unless (@suggest.to == @current_user && @suggest.to_status == Connection::PENDING) or (@suggest.from == @current_user && @suggest.from_status == Connection::PENDING)
        render :nothing => true, :status => :bad_request
      end
    end
  end

  def ensure_connected
    c_from = Connection.connection(@current_user, User.find(params[:suggest][:from_id]))
    c_to = Connection.connection(@current_user, User.find(params[:suggest][:to_id]))
    unless c_from.nil? or c_to.nil?
      if c_from.connected? and c_to.connected?
        return true
      end
    end
    render :nothing => true, :status => :bad_request
  end

end