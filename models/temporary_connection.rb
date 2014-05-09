##############################################################################
#                                                                            #
#                    COPYRIGHT 2011 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class TemporaryConnection
  include Mongoid::Document
  include Mongoid::Timestamps
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  # Token field
  field :token, :type => String
  index({ token: 1 }, { unique: true })
  # Personas array
  # field :personas, :type => Array
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  # attr_accessible :token, :personas
  attr_accessible :token
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # Define the connection participants
  belongs_to :user
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # Check that the object contains the necessary elements
  # validates :personas, :presence => true
  # Check that the token is present & unique
  validates :token, :presence => true, :uniqueness => true
  # Check that the owner-token pairis unique
  validates :user_id, :presence => true, :uniqueness => {:scope => :token}
  # Ensure that the personas are coherent with owner
  # before_save :ensure_personas_belong_to_owner  
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
  ############################################################################
  # PRIVATE METHODS BLOCK
  ############################################################################
  #
  private
  #
  #----------------------------- CALLBACK METHODS ----------------------------
  #
  # # Callback method to ensure that the personas belong to the owner
  # def ensure_personas_belong_to_owner
  #   unless self.personas.reject {|x| self.user.personas.find(x).nil? == false}.empty?
  #     errors.add(:base, I18n.t('connection.incongruent-user-persona'))
  #     return false
  #   end
  # end
  #
end
