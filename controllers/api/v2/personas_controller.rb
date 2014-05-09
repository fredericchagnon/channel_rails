##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::PersonasController < ApiController
  #
  #---------------------------------------------------------------------------
  #
  before_filter :find_persona, :only => [:show, :update]
  #
  #---------------------------------------------------------------------------
  #
  # GET /personas.json
  def index
    custom_responder(@personas = @current_user.personas.all)
  end

  # GET /personas/:id.json
  def show
    custom_responder(@persona)
  end

  # # POST /personas.json
  # def create
  #   @persona = @current_user.personas.build(params[:persona])
  #   if @persona.save
  #     custom_responder(@persona)
  #   else
  #     render :nothing => true, :status => :bad_request
  #   end
  # end

  # PUT /personas/:id.json
  def update
    @persona.update_attributes(params[:persona])
    custom_responder(@persona)
  end

  # # DELETE /personas/:id.json
  # def destroy
  #   @persona.destroy
  #   custom_responder(@persona)
  # end

  protected

  def find_persona
    @persona = @current_user.personas.find(params[:persona][:id])
    render :nothing => true, :status => :bad_request if @persona.nil?
  end

end