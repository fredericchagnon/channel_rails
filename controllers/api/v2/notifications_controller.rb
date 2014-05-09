##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::NotificationsController < ApiController
  require 'ostruct'
  #
  #---------------------------------------------------------------------------
  #
  before_filter :find_notification, :only => [:destroy]
  #
  #---------------------------------------------------------------------------
  #
  # GET /notifications.json
  def index
    @notifications = @current_user.notifications({})
    respond_with(@notifications)
    # @incoming_requests = Connection.to_user(@current_user).conn_pending
    # @outgoing_requests = Connection.from_user(@current_user).conn_pending
    # @incoming_from_suggests = Connection.all_of(from_id: @current_user.id, from_status: Connection::PENDING)
    # @incoming_to_suggests = Connection.all_of(to_id: @current_user.id, to_status: Connection::PENDING).excludes(from_status: Connection::REQUESTED)
    # @outgoing_suggests = Connection.by_user(@current_user).sugg_all_pending
    # render "api/v2/notifications/index"
    # incoming_requests = Connection.to_user(@current_user).conn_pending
    # outgoing_requests = Connection.from_user(@current_user).conn_pending
    # incoming_from_suggests = Connection.all_of(from_id: @current_user.id, from_status: Connection::PENDING)
    # incoming_to_suggests = Connection.all_of(to_id: @current_user.id, to_status: Connection::PENDING).excludes(from_status: Connection::REQUESTED)
    # outgoing_suggests = Connection.by_user(@current_user).sugg_all_pending
    # ireq = []
    # incoming_requests.each do |ic|
    #   ireq << {:id => ic.id, :from_id => ic.from_id, :from_name => ic.from.primary_persona.first_name + " " + ic.from.primary_persona.last_name, :from_persona_id => ic.from.primary_persona.id}
    # end
    # oreq = []
    # outgoing_requests.each do |oc|
    #   oreq << {:id => oc.id, :to_id => oc.to_id, :to_name => oc.to.primary_persona.first_name + " " + oc.to.primary_persona.last_name, :to_persona_id => oc.to.primary_persona.id}
    # end
    # ifsug = []
    # incoming_from_suggests.each do |oc|
    #   ifsug << {:id => oc.id, :other_id => oc.to_id, :by_id => oc.by_id, :other_name => oc.to.primary_persona.first_name + " " + oc.to.primary_persona.last_name, :other_persona_id => oc.to.primary_persona.id, :by_name => oc.by.primary_persona.first_name + " " + oc.by.primary_persona.last_name, :by_persona_id => oc.by.primary_persona.id} 
    # end
    # itsug = []
    # incoming_to_suggests.each do |oc|
    #   itsug << {:id => oc.id, :other_id => oc.from_id, :by_id => oc.by_id, :other_name => oc.from.primary_persona.first_name + " " + oc.from.primary_persona.last_name, :other_persona_id => oc.from.primary_persona.id, :by_name => oc.by.primary_persona.first_name + " " + oc.by.primary_persona.last_name, :by_persona_id => oc.by.primary_persona.id}
    # end
    # osug = []
    # outgoing_suggests.each do |oc|
    #   osug << {:id => oc.id, :from_id => oc.from_id, :to_id => oc.to_id, :from_name => oc.from.primary_persona.first_name + " " + oc.from.primary_persona.last_name, :from_persona_id => oc.from.primary_persona.id, :to_name => oc.to.primary_persona.first_name + " " + oc.to.primary_persona.last_name, :to_persona_id => oc.to.primary_persona.id}
    # end
    # notfc = {:incoming_requests => ireq, :outgoing_requests => oreq, :incoming_from_suggests => ifsug, :incoming_to_suggests => itsug, :outgoing_suggests => osug}
    # # @notifications = OpenStruct.new
    # # @notifications.marshal_load(notfc)
    # @notifications = notfc.to_ostruct
    # respond_with(@notifications)
    # # render "api/v2/notifications/index"
  end

  # DELETE /notifications/:id.json
  def destroy
    @notification.destroy
    respond_with(@notification)
  end

  protected

  def find_notification
    @notification = Connection.from_user(@current_user).conn_pending.find(params[:notification][:id])
    @notification ||= Connection.by_user(@current_user).sugg_all_pending.find(params[:notification][:id])
    render :nothing => true, :status => :bad_request if @notification.nil?
  end

end