class GrocerWorker
  include Sidekiq::Worker
  # Will try sending Apple Push Notification only once - no retries if error raised
  sidekiq_options :retry => false

  # Initialize the Grocer Pusher (this keeps connection alive with APNS Servers)
  pusher = Grocer.pusher(
    certificate: "#{Rails.root}/config/apns/production.pem",
    passphrase:  "closefisted2)overprotectiveness",
    gateway:     "gateway.push.apple.com",
    port:        2195,
    retries:     3
  )
  
  # Function that is called from within Model to push a notification
  def perform(token, alert, badge)
    notification = Grocer::Notification.new(
      device_token: token,
      alert:        alert,
      badge:        badge
    )
    pusher.push(notification)
  end
end
