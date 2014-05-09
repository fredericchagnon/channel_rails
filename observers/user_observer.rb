class UserObserver < Mongoid::Observer
  def after_save(user)
    # This obsverver should only fire an action on a valid contact_handle (for normal queue matching)
    unless user.contact_handles.where(value: user.email).first.nil?
      # Don't do anything if the contact_handle is already verified
      if user.confirmation_token.nil? and user.contact_handles.where(value: user.email).first.verified == false
        # Clear connection queue of the email that was just verified
        ConnectionQueue.verify_email(user, [user.email])
        # Set the contact_handle to verified
        user.contact_handles.where(value: user.email).first.update_attribute(:verified, true)
        user.save
      end
    end
    # This observer is for facebook matching
    unless user.facebook_id.nil?
      # Clear connection queue of the facebook_id that was just updated
      ConnectionQueue.verify_facebook(user, [user.facebook_id])
    end
  end
end