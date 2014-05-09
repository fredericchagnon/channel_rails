class GoogleImportWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false
  
  def perform(channel_token, token)
    user = User.where(external_token: channel_token).first
    unless user.nil? && user.external_token.nil?
      client = GData::Client::Contacts.new
      client.authsub_token = token
      session_token = client.auth_handler.upgrade
      client.authsub_token = session_token
      contacts_xml = client.get('https://www.google.com/m8/feeds/contacts/default/base?max-results=10000').to_xml
      email = contacts_xml.elements.first.text.downcase.to_s
      etag = contacts_xml.root.attributes['gd:etag'].to_s
      # If the user does not have a contact handle with the email he used to sign into Google, we create one automatically
      if user.contact_handles.where(:value => email).first.nil?
        user.contact_handles.create({:url => "Email", :name => "Gmail", :value => email, :public_flag => user.public_flag}, Email)
      end
      # Create or update the user's import memory
      source = user.contact_imports.where(:source => "Google").first
      if source.nil?
        user.contact_imports.create(:source => "Google", :version => etag, :auth_token => session_token)
      else
        source.update_attributes(:version => etag, :auth_token => session_token)
      end
      email_array = []
      contacts_xml.elements.each('entry') do |entry|
        if entry.elements['gd:email']
          email = entry.elements['gd:email'].attributes['address'].to_s
          name = entry.elements['title'].text.to_s
          google_id = entry.elements['id'].text.to_s
          etag = entry.attributes['gd:etag'].to_s
          email_array << {email: email, name: name, google_id: google_id, etag: etag}
        end
      end
      user.import(email_array)
    end
  end
end
