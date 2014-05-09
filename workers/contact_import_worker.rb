class ContactImportWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false
  
  def perform(uid, email_array)
    user = User.find(uid)
    unless user.nil?
      user.import(email_array)
    end
  end
end
