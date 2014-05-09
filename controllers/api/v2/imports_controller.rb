##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Api::V2::ImportsController < ApiController
  #
  #---------------------------------------------------------------------------
  #
  # POST /imports/create.json
  def create
    ContactImportWorker.perform_async(@current_user.id, params[:imports])
    render :nothing => true, :status => :ok
    # status = @current_user.import(params[:imports])
    # if status
    #   render :nothing => true, :status => :ok
    # else
    #   render :nothing => true, :status => :bad_request
    # end
  end

  # POST /imports/google.json
  def google
    if params[:sync_google] == true
      # create a unique token for the user for authentication on the callback call
      token = Devise.friendly_token[0,20]
      @current_user.update_attributes(:external_token => token)
      scope = 'http://www.google.com/m8/feeds/'
      next_url = "https://api.channel-app.com/api/v2/import_callbacks/google?channel_token="+token.to_s
      secure = false
      sess = true
      authsub_link = GData::Auth::AuthSub.get_url(next_url, scope, secure, sess)
      render :json => {:url => authsub_link}, :status => :ok
    elsif params[:sync_google] == false
      if @current_user.contact_imports.where(:source => "Google").destroy
        @current_user.update_attributes(:external_token => nil)
        render :nothing => true, :status => :ok
      else
        render :nothing => true, :status => :bad_request
      end
    else
      render :nothing => true, :status => :bad_request
    end
  end

  # POST /imports/facebook.json
  def facebook
    if params[:sync_facebook] == true
      # create a unique token for the user for authentication on the callback call
      token = Devise.friendly_token[0,20]
      @current_user.update_attributes(:external_token => token)
      callback_url = "https://api.channel-app.com/api/v2/import_callbacks/facebook?channel_token="+token.to_s
      client_id = "101520159963772"
      secret_id = "96f234be871c958762798fb4c5ea0118"
      client = FBGraph::Client.new(:client_id => client_id, :secret_id => secret_id)
      authsub_link = client.authorization.authorize_url(:redirect_uri => callback_url , :scope => 'friends_about_me')
      render :json => {:url => authsub_link}, :status => :ok
    elsif params[:sync_facebook] == false
      if @current_user.contact_imports.where(:source => "Facebook").destroy
        @current_user.update_attributes(:external_token => nil)
        render :nothing => true, :status => :ok
      else
        render :nothing => true, :status => :bad_request
      end
    else
      render :nothing => true, :status => :bad_request
    end
  end

end