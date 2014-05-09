##############################################################################
#                                                                            #
#                    COPYRIGHT 2011 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class PersonaHandle
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Validations
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  # The rank field is an integer with a default of -1 (which signifies that
  # the contact_handle persona tuple is inactive)
  field :rank, :type => Integer, :default => -1
  field :enabled, :type => Boolean, :default => false
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  # Set accessible attributes
  attr_accessible :rank, :enabled, :persona_id, :protocol_id
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # A PersonaHandle is a soft join table that associates a contact handle's 
  # protocol to a persona with a rank for a given status
  embedded_in :status
  belongs_to :persona
  belongs_to :protocol
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # Ensure that a PersonaHandle has a "rank" & ids of owners
  validates_presence_of :rank, :persona_id, :protocol_id
  # Ensure that the rank is an integer
  validates_numericality_of :rank, :only_integer => true
  # Make sure that there is only one persona-protocol pair for each status
  validates_uniqueness_of :persona_id, :scope => :protocol_id 
  # Ensure that enabled is a boolean
  validates :enabled, inclusion: {in: [true, false]}
  # Ensure that the persona_id and protocol_id are consistent
  before_save :ensure_persona_coherence, :ensure_protocol_coherence
  #
  ############################################################################
  # SCOPE BLOCK
  ############################################################################
  #
  scope :enabled, where(enabled: true)
  scope :disabled, where(enabled: false)
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
  # Callback method to ensure that persona_id is consistent
  def ensure_persona_coherence
    if self.status.user.personas.find(self.persona_id).nil?
      errors.add(:base, 'Inconsistent persona handle persona')
      return false
    end
  end
  #
  # Callback method to ensure that protocol_id is consistent
  def ensure_protocol_coherence
    # if self.status.user.contact_handles.where("protocols._id" => self.protocol_id).first.nil?
    unless self.status.user.contact_handles.collect {|x| x.protocols.collect {|p| p.id}}.flatten.include?(self.protocol_id)
      errors.add(:base, 'Inconsistent persona handle protocol')
      return false
    end
  end
  #
end