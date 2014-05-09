##############################################################################
#                                                                            #
#                    COPYRIGHT 2011 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Connection
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Validations
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  # Status attributes to determine state of connection
  field :from_status, :type => Integer, :default => nil
  field :to_status, :type => Integer, :default => nil
  field :from_persona_ids, :type => Array, :default => []
  field :to_persona_ids, :type => Array, :default => []
  # New field to track whether a connection is "normal" or a result of a 
  # cleared "queue" item. Had to insert this field to track this because it
  # is currently impossible to do a query to find where(:from_id => :by_id)
  # in Mongoid/MongoDB
  field :queue, :type => Boolean, :default => false
  #
  # Status codes (CONSTANT VALUES): -> MOVED TO GLOBAL CONSTANTS
  REQUESTED = 0
  PENDING   = 1
  ACCEPTED  = 2
  REJECTED  = 3
  SEVERED   = 4
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  # Connections can be requested (i.e. may I connect with you?) or suggested
  # (i.e. may I suggest that you connect with so-and-so?). In the latter case,
  # suggections can only be made to two people who are already connected with
  # the suggestor. To keep track of these different types of connection models
  # two statuses are introduced: "to_status" and "from_status".
  #
  # Connection have the following prossibilities and the methods implemented
  #
  # -------------------------------------------------------------------------
  #   from_status  |  to_status  |     Connection Status     |    Method
  # -------------------------------------------------------------------------
  #                |             |                           |
  #   REQUESTED    |  PENDING    |       requested           |   requested?
  #    PENDING     |  PENDING    |       suggested           |   suggested?
  #   ACCEPTED     |  ACCEPTED   |       connected           |   connected?
  #   REQUESTED    |  REJECTED   |  requested_to_rejected    |   rejected?
  #    PENDING     |  ACCEPTED   |  suggested_to_accepted    |  to_accepted?
  #   ACCEPTED     |  PENDING    |  suggested_from_accepted  | from_accepted?
  #   REJECTED     |  PENDING    |  suggested_from_rejected  |   rejected?
  #    PENDING     |  REJECTED   |   suggested_to_rejected   |   rejected?
  #   ACCEPTED     |  REJECTED   | from_accepted_to_rejected |   rejected?
  #   REJECTED     |  ACCEPTED   | from_rejected_to_accepted |   rejected?
  #   REJECTED     |  REJECTED   |         rejected          |   rejected?
  #   ACCEPTED     |  SEVERED    |        to_severed         |    severed?
  #    SEVERED     |  ACCEPTED   |       from_severed        |    severed?
  #                |             |                           |
  # -------------------------------------------------------------------------
  #
  # Setup accessible (or protected) attributes for your model
  attr_accessible :from_status, :to_status, :queue, :from_id, :to_id, :by_id,
    :from_persona_ids, :to_persona_ids
  #
  # Index 
  index({ from_id: 1, to_id: 1, by_id: 1 }, { unique: true, background: true })
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # Define the connection participants
  belongs_to :from,  :class_name => "User"
  belongs_to :to,    :class_name => "User"
  belongs_to :by,    :class_name => "User"
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # Check that the object contains the necessary elements
  validates_presence_of :from_id, :to_id, :by_id, :to_status, :from_status
  # Ensure that the statuses are integers
  validates_numericality_of :from_status, :only_integer => true, 
    :greater_than_or_equal_to => 0, :less_than_or_equal_to => 4
  validates_numericality_of :to_status, :only_integer => true, 
    :greater_than_or_equal_to => 0, :less_than_or_equal_to => 4
  # Ensure that each connection is "unique" (from, to) pair
  validates :from_id, :uniqueness => {:scope => :to_id, :message => I18n.t('connection.already-exists')}
  before_create :ensure_unique_connected_couple
  # The following are handled by the validations above 
  # validate :ensure_statuses_not_nil, :ensure_owners_not_nil -> REMOVED
  validate :ensure_coherent_owners_suggest #-> REMOVED BC CONNECTION QUEUE USES THIS
  validate :ensure_connection_valid, :ensure_coherent_owners, 
    :ensure_coherent_owners_request, :ensure_from_and_to_are_not_the_same
  # Ensure that the to_ and from_ personas are coherent with to_id and from_id
  before_save :ensure_personas_belong_to_users
  # Clean-up all favorites associated with connection before destroying
  before_destroy :destroy_associated_favorites
  #
  ############################################################################
  # SCOPE BLOCK
  ############################################################################
  #
  # scope blocks to define :to, :from and :by users
  scope :from_user, lambda { |user| where(:from_id    => user.id) }
  scope :to_user,   lambda { |user| where(:to_id      => user.id) }
  scope :by_user,   lambda { |user| where(:by_id      => user.id) }
  scope :not_from,  lambda { |user| excludes(:from_id => user.id) }
  scope :not_to,    lambda { |user| excludes(:to_id   => user.id) }
  scope :not_by,    lambda { |user| excludes(:by_id   => user.id) }
  scope :from_or_to,lambda { |user| any_of( {:from_id => user.id}, 
    { :to_id => user.id } ) }
  #
  scope :active, where(from_status: ACCEPTED, to_status: ACCEPTED)
  scope :conn_pending, where(from_status: REQUESTED, to_status: PENDING)
  scope :sugg_all_pending, where(from_status: PENDING, to_status: PENDING)
  scope :sugg_to_pending, where(from_status: ACCEPTED, to_status: PENDING)
  scope :sugg_from_pending, where(from_status: PENDING, to_status: ACCEPTED)
  scope :queued, where(queue: true)
  scope :notqueued, where(queue: false)
  #
  ############################################################################
  # PUBLIC METHODS BLOCK
  ############################################################################
  #
  public
  #
  #----------- METHOD THAT RETURNS CONTACT INFO FROM USER/CONNECTION ---------
  #
  def contact(calling_user)
    result = OpenStruct.new
    result.connection_id = self.id
    if calling_user.favorites.where(connection_id: self.id).first.nil?
      result.favorite = false
    else
      result.favorite = true
    end
    if self.from == calling_user
      user =  self.to
      result.my_personas = self.from_persona_ids
      result.user_id = user.id
      result.home_me = user.contact_info("Home", self.to_persona_ids)
      result.work_me = user.contact_info("Work", self.to_persona_ids)
    elsif self.to == calling_user
      user = self.from
      result.my_personas = self.to_persona_ids
      result.user_id = user.id
      result.home_me = user.contact_info("Home", self.from_persona_ids)
      result.work_me = user.contact_info("Work", self.from_persona_ids)
    end
    return result
  end
  #
  #------------------- METHOD THAT DISCONNECTS A CONNECTION ------------------
  #
  def disconnect(user)
    if user == self.from
      self.update_attributes(from_status: SEVERED)
    elsif user == self.to
      self.update_attributes(to_status: SEVERED)
    end
    destroy_associated_favorites
  end
  #
  #---------------- QUERY METHODS TO RETURN CONNECTION STATUS ----------------
  #
  # Method to verify if a connection was requested
  def requested?
    self.from_status==REQUESTED and self.to_status==PENDING
  end  
  #
  # Method to verify if a connection was accepted
  def connected?
    self.from_status==ACCEPTED and self.to_status==ACCEPTED
  end
  #
  # Method to verify if a connection was suggested in any state
  def any_suggested?
    (self.from_status==PENDING and self.to_status==PENDING) or \
    (self.from_status==PENDING and self.to_status==ACCEPTED) or \
    (self.from_status==ACCEPTED and self.to_status==PENDING)
  end
  #
  # Method to verify if a connection was suggested and is two-sided pending
  def suggested?
    self.from_status==PENDING and self.to_status==PENDING
  end
  #
  # Method to verify if a connection was suggested and is pending from_
  def to_accepted?
    self.from_status==PENDING and self.to_status==ACCEPTED
  end
  #
  # Method to verify if a connection was suggested and is pending to_
  def from_accepted?
    self.from_status==ACCEPTED and self.to_status==PENDING
  end
  #
  # Method to verify if a connection was rejected
  def rejected?
    self.from_status==REJECTED or self.to_status==REJECTED
  end
  #
  # Method to verify if a connection was severed
  def severed?
    self.from_status==SEVERED or self.to_status==SEVERED
  end
  #
  # Method to verify if a user is one of the connection's owners
  def owner?(user)
    return false if user.nil?
    self.from_id == user.id or self.to_id == user.id
  end
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
    #
    #-------------- QUERY METHODS TO RETURN DESIRED CONNECTION ---------------    
    #
    # Method to return a connection between two users, regardless of status
    # ** NOTE THAT THIS METHOD IS NON-DIRECTIONAL AS IT RETURNS A CONNECTION
    # REGARDLESS OF WHO IS "FROM" AND WHO IS "TO"
    # This method is "flexible" in that it can either receive as arguments 
    # user objects or user ids - there must be a more elegant way of 
    # making this method "flexible"
    def connection(user1, user2)
      if user1.class == User and user2.class == User
        Connection.where(:from_id => user1.id, \
        :to_id => user2.id).first or \
        Connection.where(:from_id => user2.id, :to_id => user1.id).first
      elsif user1.class == Moped::BSON::ObjectId and user2.class == Moped::BSON::ObjectId
        Connection.where(:from_id => user1, :to_id => user2).first \
        or Connection.where(:from_id => user2, :to_id => user1).first
      end
    end
    # #
    # # Method that returns the opposing party in a connection. Returns as 
    # # User object
    # def counterparty(connection, user)
    #   if connection.from_id == user.id
    #     return connection.to
    #   elsif connection.to_id == user.id
    #     return connection.from
    #   end
    # end
    #
    #-------------- ACTION METHODS TO CHANGE CONNECTION STATUS ---------------
    #
    #
    # Request a connection. params => {from_id, to_id, from_persona_ids}
    # The following scenarios are handled:
    # 1) No connection/request/suggestion exists -> submit request
    # 2) An incoming request already exists -> accept and connect
    # 3) A suggestion from a 3rd party already exists -> accept one-side
    def request(params={})
      from = User.find(params[:from_id])
      to = User.find(params[:to_id])
      c = Connection.connection(from, to)
      from_personas = params[:from_persona_ids].collect {|x| from.personas.find(x).id}
      if c.nil?
        c = self.create(params.merge({by_id: from.id, from_status: REQUESTED, to_status: PENDING}))
      elsif c.requested? && from.id == c.to_id
        c.update_attributes({to_persona_ids: from_personas, from_status: ACCEPTED, to_status: ACCEPTED})
      elsif c.any_suggested?
        if from.id == c.from_id
          c.update_attributes({from_persona_ids: from_personas, from_status: ACCEPTED})
        elsif from.id == c.to_id
          c.update_attributes({to_persona_ids:from_personas, to_status: ACCEPTED})
        end
      else
        return :conflict
      end
      return c
    end
    #
    # Suggest a connection. params => {by_id, from_id, to_id}
    # The following scenarios are handled:
    # 1) No connection/request/suggestion exists -> submit suggestion
    def suggest(params={})
      # Get a handle on the connection (returns "nil" if none exist)
      # c = Connection.connection(params[:from_id], params[:to_id])
      from = User.find(params[:from_id])
      to = User.find(params[:to_id])
      c = Connection.connection(from, to)
      if c.nil?
        self.create(params.merge({from_status: PENDING, to_status: PENDING}))
      else
        return :conflict
      end
    end
    #
    # Method to unqueue a connection_queue. Arguments: from, to
    def unqueue(from, to)
      if Connection.connection(from, to).nil?
        Connection.create({from_id: from.id, to_id: to.id, by_id: from.id,
          from_status: PENDING, to_status: PENDING, queue: true})
      else
        return false
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
  #----------------------------- CALLBACK METHODS ----------------------------
  #
  def ensure_unique_connected_couple
    unless Connection.where(from_id: self.to_id, to_id: self.from_id).first.nil?
      errors.add(:connection, I18n.t('connection.already-exists'))
      return false
    end
  end
  #
  # Callback Method to ensure that the from_ and to_ statuses are not the same
  def ensure_from_and_to_are_not_the_same
    if self.from_id == self.to_id
      errors.add(:connection, I18n.t('connection.from-and-to-same'))
      return false
    end
  end
  #
  # Callback to ensure coherence between connection owners and connection type
  def ensure_coherent_owners_request
    if (self.from_id != self.by_id) and self.requested?
      errors.add(:connection, I18n.t('connection.cannot-submit-request'))
      return false
    end
  end
  #
  # Callback to ensure coherence between connection owners and connection type
  def ensure_coherent_owners_suggest
    if (self.from_id == self.by_id) and self.suggested? and self.queue == false
      errors.add(:connection, I18n.t('connection.cannot-submit-suggestion'))
      return false
    end
  end
  #
  # Callback to ensure coherence between connection owners and connection type
  def ensure_coherent_owners
    if self.to_id == self.by_id
      errors.add(:connection, I18n.t('connection.cannot-submit-suggestion'))
      return false
    end
  end
  #
  # Callback method to ensure that the connection is in a valid state
  # Invalid states are as follows:
  # 1) from_status    = PENDING   & to_status      = REQUESTED
  # 2) from_status    = REQUESTED & to_status      = REQUESTED
  # 3) from/to_status = REQUESTED & to/from_status = ACCEPTED
  # 4) from/to_status = REQUESTED & to/form_status = SEVERED
  # 5) from/to_status = PENDING   & to/from_status = SEVERED
  # 6) from/to_status = REJECTED  & to/from_status = SEVERED
  # 7) from_status    = SEVERED   & to_status      = SEVERED
  # 8) from_status    = REJECTED  & to_status      = REQUESTED
  def ensure_connection_valid
    if (self.from_status == PENDING  and self.to_status == REQUESTED) or \
      (self.from_status == REQUESTED and self.to_status == REQUESTED) or \
      (self.from_status == REQUESTED and self.to_status == ACCEPTED)  or \
      (self.from_status == ACCEPTED  and self.to_status == REQUESTED) or \
      (self.from_status == REQUESTED and self.to_status == SEVERED)   or \
      (self.from_status == SEVERED   and self.to_status == REQUESTED) or \
      (self.from_status == PENDING   and self.to_status == SEVERED)   or \
      (self.from_status == SEVERED   and self.to_status == PENDING)   or \
      (self.from_status == REJECTED  and self.to_status == SEVERED)   or \
      (self.from_status == SEVERED   and self.to_status == REJECTED)  or \
      (self.from_status == SEVERED   and self.to_status == SEVERED)   or \
      (self.from_status == REJECTED  and self.to_status == REQUESTED)
      errors.add(:connection, I18n.t('connection.incongruent-statuses'))
      return false
    end
  end
  #
  # Callback method to ensure that the from_personas belong to the from_user
  # and that the to_personas belong to the to_user
  def ensure_personas_belong_to_users
    # Check to-side
    unless self.to_persona_ids.reject {|x| User.find(self.to_id).personas.find(x).nil? == false}.empty?
      errors.add(:base, I18n.t('connection.incongruent-user-persona'))
      return false
    end
    # Check from-side
    unless self.from_persona_ids.reject {|y| User.find(self.from_id).personas.find(y).nil? == false}.empty?
      errors.add(:base, I18n.t('connection.incongruent-user-persona'))
      return false
    end
  end
  #
  # Method to destroy associated favorites
  def destroy_associated_favorites
    self.from.favorites.where(connection_id: self.id).destroy_all
    self.to.favorites.where(connection_id: self.id).destroy_all
  end
  #
end
