##############################################################################
#                                                                            #
#                    COPYRIGHT 2011 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class ContactMeBack
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Validations
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  # scope blocks to define :to, :from and :by users
  scope :from,  lambda { |user| where(:from_id => user.id) }
  scope :to,    lambda { |user| where(:to_id   => user.id) }
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  # Connections can be requested (i.e. please contact me back) and can only be 
  # made to people who are already actively connected with the requestor
  attr_accessible :from_id, :to_id, :updated_at
  # index from_id & to_id to improve db perf
  index({ from_id: 1, to_id: 1 }, { unique: true })
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # Define the connection participants
  belongs_to :from,  :class_name => "User"
  belongs_to :to,    :class_name => "User"
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  validates_presence_of :from_id, :to_id
  validate :ensure_from_and_to_are_not_the_same
  validate :ensure_actively_connected
  # before_create :ensure_cmb_unique
  validates_uniqueness_of :from_id, :scope => [:to_id]
  after_create :send_push_notification
  #
  ############################################################################
  # SCOPE BLOCK
  ############################################################################
  #
  scope :from_owner, ->(user_id) {where(from_id: user_id)}
  scope :to_owner, ->(user_id) {where(to_id: user_id)}
  #
  ############################################################################
  # PUBLIC METHODS BLOCK
  ############################################################################
  #
  public
  #
  #---------------- QUERY METHODS TO RETURN CONNECTION STATUS ----------------
  #
  # Method to verify if a user is the cmb's originator
  def from_owner?(id)
    self.from_id == id
  end
  # Method to verify if a user is the cmb's addressee
  def to_owner?(id)
    self.to_id == id
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
    #-------------- ACTION METHODS TO CREATE/DELETE CMB ----------------------
    #
    # Method to request a cmb. Arguments: from and to
    # The following scenarios are handled:
    # 1) No request exists -> submit request
    # 2) An outgoing request already exists -> refresh time stamp
    # 3) An incoming request already exists -> delete and set new
    def request(params={})
      cmb = ContactMeBack.cmb(params[:from_id], params[:to_id])
      if cmb.nil?
        self.create(params)
      elsif cmb.from_owner?(params[:from_id])
        cmb.update_attributes(updated_at: Time.now)
      elsif cmb.to_owner?(params[:from_id])
        self.create(params) if cmb.destroy
      else
        return false
      end
    end
    #
    #-------------- QUERY METHODS TO RETURN DESIRED CONNECTION ---------------    
    #
    # Method to return a cmb between two users
    # ** NOTE THAT THIS METHOD IS NON-DIRECTIONAL AS IT RETURNS A CMB
    # REGARDLESS OF WHO IS "FROM" AND WHO IS "TO"
    def cmb(u1, u2)
      ContactMeBack.where(:from_id => u1, :to_id => u2).first || \
      ContactMeBack.where(:from_id => u2, :to_id => u1).first
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
  # Callback Method to ensure that the from_ and to_ statuses are not the same
  def ensure_from_and_to_are_not_the_same
    if self.from_id == self.to_id
      errors.add(:contact_me_back, I18n.t('cmb.from-and-to-same'))
      return false
    end
  end
  #
  # Callback to ensure that cmb participants have an active connection
  def ensure_actively_connected
    c = Connection.connection(self.from_id, self.to_id)
    if c.nil? or c.connected? == false
      errors.add(:contact_me_back, I18n.t('cmb.from-and-to-not-connected'))
      return false      
    end
  end
  #
  # Callback Method to send a push notification after CMB creation
  def send_push_notification
    unless self.to.devices.empty?
      unless self.to.devices.where(url: "iPhone").empty?
        unless self.to.devices.where(url: "iPhone").first.push_token.nil?
          token = self.to.devices.where(url: "iPhone").first.push_token
          alert = I18n.t('cmb.request_message', :name => self.from.personas.first.first_name + " " + self.from.personas.first.last_name)
          count = ContactMeBack.where(to_id: self.to.id).count
          GrocerWorker.perform_async(token, alert, count)
        end
      end
    end
  end
  #
end
