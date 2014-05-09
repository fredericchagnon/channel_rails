class FacebookImportWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false
  
  def perform(channel_token, code)
    user = User.where(external_token: channel_token).first
    unless user.nil? && user.external_token.nil?
      client_id = "101520159963772"
      secret_id = "96f234be871c958762798fb4c5ea0118"
      client = FBGraph::Client.new(:client_id => client_id, :secret_id => secret_id)
      access_token = client.authorization.process_callback(code, :redirect_uri => "https://api.channel-app.com/api/v2/import_callbacks/facebook?channel_token="+channel_token)
      client = FBGraph::Client.new(:client_id => client_id, :secret_id => secret_id, :token => access_token)
      about_me = client.selection.me.info!
      email = about_me.email.downcase.to_s
      facebook_id = about_me.id
      etag = about_me.updated_time
      friends_hash = client.selection.me.friends.info!
      # Store the user's facebook_id to connect hinm/her with other users in future
      user.update_attribute(:facebook_id, facebook_id)
      # If the user does not have a contact handle with the email he used to sign into Google, we create one automatically
      if user.contact_handles.where(:value => email).first.nil?
        user.contact_handles.create({:url => "Email", :name => "Facebook Email", :value => email, :public_flag => user.public_flag}, Email)
      end
      # Create or update the user's import memory
      source = user.contact_imports.where(:source => "Facebook").first
      if source.nil?
        user.contact_imports.create(:source => "Facebook", :version => etag, :auth_token => access_token)
      else
        source.update_attributes(:version => etag, :auth_token => access_token)
      end
      facebook_id_array = []
      friends_hash.first[1].each do |entry|
        facebook_id_array << {name: entry.name, facebook_id: entry.id, etag: etag}
      end
      user.import(facebook_id_array)
    end
  end
end
