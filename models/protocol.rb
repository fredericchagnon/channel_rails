##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Protocol
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Validations
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  # Each Protocol has a type
  field :type, :type => String
  # A Protocol has a flag to determine whether it is "active". This is 
  # used to determine whether this protocol is available for the contact
  # handle it belongs to
  field :active, :type => Boolean, :default => true
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  attr_accessible :type, :active
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # Each protocol is embedded in a contact handle
  embedded_in :contact_handle
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # Require basic information (the presence of active is implict in the check
  # a few lines below that active is Boolean. We cannot put active here since
  # the boolean value of false is seen as "not present")
  validates_presence_of :type
  # Make sure the protocols are unique for their respective contact handles
  validates_uniqueness_of :type, :scope => :contact_handle_id
  # Ensure that type is acceptable
  validates_inclusion_of :type, :in => ALL_PROTOCOL_VALUES
  # Ensure that active is a boolean
  validates_inclusion_of :active, :in => [true, false]
  # Ensure that the type has a value that is allowed
  after_validation :validate_protocols_type_for_contact_handle_url
  # Ensure that the persona handles are up to date after update
  after_update :update_persona_handles
  #
  ############################################################################
  # SCOPE BLOCK
  ############################################################################
  #
  scope :active, where(active: true)
  scope :inactive, where(active: false)
  #
  ############################################################################
  # PUBLIC METHODS BLOCK
  ############################################################################
  #
  public
  #
  def active?
    active == true
  end
  def inactive?
    active == false
  end
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
  # Callback that makes sure that the protocol type is consistent with the 
  # contact handle url
  def validate_protocols_type_for_contact_handle_url
    begin
      unless (self.contact_handle.url.upcase+"_PROTOCOLS").constantize.include?(self.type)
        errors.add(:base, 'Inconsistent protocol type for contact handle')
        return false
      end
    rescue
      return false
    end
  end
  #
  # Method to keep persona handles up to date after update
  def update_persona_handles
    self.contact_handle.user.statuses.each do |s|
      if self.active?
        self.contact_handle.user.personas.each do |p|
          if s.persona_handles.all_of(persona_id: p.id, protocol_id: self.id).empty?
            s.persona_handles.create({persona_id: p.id, protocol_id: self.id})
          end
        end
      elsif self.inactive?
        s.persona_handles.where(protocol_id: self.id).destroy_all
      end
    end
  end
  #
end
