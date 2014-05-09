##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class ContactHandle
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Validations
  # include Mongoid::OptimisticLocking
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  # Each Contact Handle has a name (e.g. "Work Phone")
  field :name, :type => String
  # Each Contact Handle has a url (e.g. Telephone, iPhone, Email, Address, SMS)
  field :url, :type => String
  # Each Contact Handle has a value that stores the actual address info (e.g.
  # email address, telephone number) - validations are handled by the 
  # corresponding sub-classes
  field :value, :type => String
  field :country_code, type: String, default: nil
  # Each Contact Handle has a flag to tell whether it has been verified (to
  # prevent impersonation)
  field :verified, :type => Boolean, :default => false
  # A ContactHandle has a flag to determine whether it is is Public (i.e. 
  # searchable and viewable by all); Normal (i.e. viewable by connections
  # only); Unlisted (i.e. viewable by connections only)
  # The value of the public flag is inherited by the User's public_flag
  field :public_flag, :type => Integer, :default => 0
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  attr_accessible :name, :value, :url, :protocols_attributes, :public_flag
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # Each contact handle belongs to a user
  embedded_in :user
  # Each contact handle embeds many protocols
  embeds_many :protocols, :cascade_callbacks => true
  accepts_nested_attributes_for :protocols, :autosave => true
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # Require basic information
  validates_presence_of :name, :url
  # Ensure that each contact handle name is unique for each URL
  validates_uniqueness_of :name, :scope => :url
  # Ensure that each contact handle value is unique for each URL
  validates_uniqueness_of :value, :scope => :url
  # Regularize the name of the url
  before_validation :strip_and_downcase_url
  # Ensure that verified is a boolean
  validates :verified, inclusion: {in: [true, false]}
  # Ensure that the public_flag has a value that is allowed
  # validates :public_flag, inclusion: {in: PUBLIC_FLAG_VALUES}
  validates_inclusion_of :public_flag, in: PUBLIC_FLAG_VALUES
  # Make sure that the contact handle URL is supported
  validates :url, inclusion: {in: ALL_URL_VALUES.collect{|x| x.downcase}}
  # Ensure that the contact_handle's public_flag is coherent with the user's
  validate :ensure_public_flag_consistent_with_user
  # Ensure that the list of protocols is valid
  after_create :prepare_protocols
  # Callback to update all persona handles on create & destroy actions
  after_create :create_persona_handles
  after_destroy :destroy_persona_handles
  #
  ############################################################################
  # SCOPE BLOCK
  ############################################################################
  #
  scope :verified, where(verified: true)
  scope :emails, where(url: "email")
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
  ############################################################################
  # PRIVATE METHODS BLOCK
  ############################################################################
  #
  private
  #
  #----------------------------- CALLBACK METHODS ----------------------------
  #
  # Method to regularize url format
  def strip_and_downcase_url
    if self.url.present?
      self.url.strip!
      self.url.downcase!
    end
  end
  #
  # Validation to ensure that the contact_handle's public_flag is coherent with
  # the user's. 
  # Invalid combinations as follows:
  # 1) user.public_flag = PUBLIC    & contact_handle.public_flag = UNLISTED
  # 1) user.public_flag = NORMAL    & contact_handle.public_flag = PUBLIC
  # 1) user.public_flag = NORMAL    & contact_handle.public_flag = UNLISTED
  # 1) user.public_flag = UNLISTED  & contact_handle.public_flag = NORMAL
  # 1) user.public_flag = UNLISTED  & contact_handle.public_flag = PUBLIC
  def ensure_public_flag_consistent_with_user
    unless self.user.nil?
      uflag = self.user.public_flag
      cflag = self.public_flag
      if (uflag ==  1 and cflag == -1) or \
        (uflag  ==  0 and cflag ==  1) or \
        (uflag  ==  0 and cflag == -1) or \
        (uflag  == -1 and cflag ==  0) or \
        (uflag  == -1 and cflag ==  1)
        errors.add(:base, 'Incoherent public_flag value')
        return false
      end
    end
  end
  #
  # Callback called before saving a contact handle object to ensure that the
  # appropriate protocols are populated and valid
  def prepare_protocols
    (self.url.upcase+"_PROTOCOLS").constantize.each do |p|
      if self.protocols.where(type: p).empty?
        self.protocols.create(type: p)
      end
    end
  end
  #
  # Method to create new persona handles for a new contact handle
  def create_persona_handles
    self.user.statuses.each do |s|
      self.user.personas.each do |p|
        self.protocols.active.each do |r|
          s.persona_handles.create(persona_id: p.id, protocol_id: r.id)
        end
      end
    end
  end
  #
  # Method to destroy persona handles when destroying a contact handle
  def destroy_persona_handles
    self.user.statuses.each do |s|
      self.protocols.each do |r|
        s.persona_handles.where(protocol_id: r.id).destroy_all
      end
    end
  end
  #
end
