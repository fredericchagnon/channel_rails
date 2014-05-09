##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class ConnectionQueue
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Validations
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  # Each connection queue item is indexed by the email of the desired user
  field :email, :type => String
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  # This model holds the logic for the QUEUE model, which is where requests to
  # people who aren't yet users of the service are stored
  #
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :user_ids
  #
  # Index
  index({ email: 1 }, { unique: true, background: true })
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # A queue element has and belongs to many users
  has_and_belongs_to_many :users
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # Ensure the presence and uniqueness of the user email
  validates_presence_of :email
  validates_uniqueness_of :email, :case_sensitive => false
  validates_format_of :email, :message => I18n.t('email.invalid'), :with => RFC822::EMAIL
  # Ensure email format is regularized (Email@Domain.COM => email@domain.com)
  before_save :strip_and_downcase_email
  # Ensure associated users are unique
  after_update :ensure_unique_users
  #
  ############################################################################
  # SCOPE BLOCK
  ############################################################################
  #
  #
  ############################################################################
  # PUBLIC METHODS BLOCK
  ############################################################################
  #
  public
  #
  #
  ############################################################################
  # PROTECTED METHODS BLOCK
  ############################################################################
  #
  protected
  #
  #
  class << self
    #
    #-------------- QUERY METHODS TO RETURN DESIRED QUEUE INST ---------------    
    #
    #
    #-------------- ACTION METHODS TO CHANGE CONNECTION STATUS ---------------
    #
    # Method to submit a queue instance. Arguments: persona and email
    # The following scenarios are handled:
    # 1) A queue item does not exist for the email -> create a new queue item
    # 2) A queue item already exists -> append to exisiting queue item
    def add(user, email)
      c = ConnectionQueue.where(email: email).first 
      # Create a new ConnectionQueue object if the email is not already there
      if c.nil?
        user.connection_queues.create(email: email)
      else
        c.users.push(user)
      end
    end
    #
    # Method to submit a queue instance. Arguments: persona and email
    # The following scenarios are handled:
    # 1) A queue item does not exist for the email -> create a new queue item
    # 2) A queue item already exists -> append to exisiting queue item
    def submit_to_queue(user, email)
      # Reject if user argument is nil
      return false if (user.nil? or user.class != User)
      # Get a handle on the connection_queue (returns "nil" if none exist)
      connq = ConnectionQueue.where(email: email).first
      # Create a new ConnectionQueue object if the email is not already there
      if connq.nil?
        user.connection_queues.create(email: email)
        return true
      # Append the user_id to the ConnectionQueue for the email if it is
      # already there
      else
        # Check to make sure the ConnectionQueue element does not already 
        # contain that specific persona
        unless connq.user_ids.include?(user.id)
          connq.push(:user_ids, user.id)
          return true
        end
      end
    end
    #
    # Method to remove a queue instance. Arguments: persona and email
    # The following scenarios are handled:
    # 1) A queue item exists and includes the persona -> remove persona from 
    # queue item
    def remove_from_queue(user, connq)
      # Reject if arguments do not make sense
      return false if (user.nil? or user.class != User or connq.nil? or \
        connq.class != ConnectionQueue)
      # Remove persona from ConnectionQueue
      if (connq.user_ids.include?(user.id))
        # This method essentially manually removed reference to the user_id
        # in the array for the ConnectionQueue item. This is ugly.
        # But if we use the destroy_all method on a criteria, it ends up
        # removing all connection_queues with that email for all Users, or
        # it removes the User item entirely... 
        connq.pull(:user_ids, user.id)
        connq.save
      else
        return false
      end
    end
    #
    # Method to move a queue instance from the queue to a connection request. 
    # Arguments: array of emails associated with persona who just updated 
    # their profile
    # The following scenarios are handled:
    # 1) A queue item exists for the email -> remove email from queue and 
    # create connection_requests for each associated persona.id
    def verify_email(user, email_array)
      # Verify integrity of arguments
      return false if (user.nil? or user.class != User or email_array.empty? \
        or email_array.class != Array)
      # Go through each email address contained in the array
      email_array.each do |e|
        # Don't know if this check is really necessary - but paranoia...
        if e.class == String
          # Find the associated ConnectionQueue item
          connq = ConnectionQueue.where(email: e).first
          # Only execute rest if connq is non nil and if email belongs to user
          if connq.nil? or user.contact_handles.where(value: e).empty?
            return false
          else
            connq.users.each do |u|
              Connection.unqueue(u, user) unless user == u
            end
            connq.destroy
            return true
          end
        end
      end
    end
    #
    # Method to move a queue instance from the queue to a connection request. 
    # Arguments: array of facebook_ids associated with user who just updated 
    # their profile
    # The following scenarios are handled:
    # 1) A queue item exists for the facebook_id -> remove facebook_id from queue and 
    # create connection_requests for each associated user.id
    def verify_facebook(user, facebookid_array)
      # Verify integrity of arguments
      return false if (user.nil? or user.class != User or facebookid_array.empty? \
        or facebookid_array.class != Array)
      # Go through each email address contained in the array
      facebookid_array.each do |e|
        # Don't know if this check is really necessary - but paranoia...
        if e.class == String
          # Find the associated ConnectionQueue item
          connq = ConnectionQueue.where(email: e+"@facebook.channel-app.com").first
          # Only execute rest if connq is non nil and if facebook_id belongs to user
          if connq.nil? or user.facebook_id != e
            return false
          else
            connq.users.each do |u|
              Connection.unqueue(u, user) unless user == u
            end
            connq.destroy
            return true
          end
        end
      end
    end
    #
  end
  #
  ############################################################################
  # PRIVATE METHODS BLOCK
  ############################################################################
  #
  private
  #
  # Method to regularize email format
  def strip_and_downcase_email
    if self.email.present?
      self.email.strip!
      self.email.downcase!
    end
  end
  #
  def ensure_unique_users
    self.user_ids.uniq!
  end
  #
end
