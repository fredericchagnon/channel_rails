##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::FavoritesController < ApiController
  #
  #---------------------------------------------------------------------------
  #
  before_filter :find_favorite, :only => [:destroy]
  #
  #---------------------------------------------------------------------------
  #
  # GET /favorites.json
  def index
    custom_responder(@favorites = @current_user.favorites.all)
  end

  # POST /favorites.json
  def create
    @favorite = @current_user.favorites.where(params[:favorite]).first
    if @favorite.nil?
      @favorite = @current_user.favorites.create(params[:favorite])
      if @favorite.save
        custom_responder(@favorite)
      else
        render :nothing => true, :status => :bad_request
      end
    else
      custom_responder(@favorite)
    end
  end

  # DELETE /favorites/:id.json
  def destroy
    @favorite.destroy
    custom_responder(@favorite)
  end

  protected

  def find_favorite
    @favorite = @current_user.favorites.where(connection_id: params[:favorite][:connection_id]).first
    # render :nothing => true, :status => :bad_request if @favorite.nil?
    render :nothing => true, :status => :ok if @favorite.nil?
  end

end