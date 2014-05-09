##############################################################################
#                                                                            #
#                    COPYRIGHT 2011 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Authenticator
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Validations
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  # The service is the name of the authenticating servcie
  field :service, :type => String
  # The uid is the user's specific user id on the service
  field :uid, :type => String
  # Declare the temporary authentication code for signing-in/up with external
  # services through omniauth
  field :token, :type => String, :default => rand(36**100).to_s(36)
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  # Setup accessible (or protected) attributes for your model
  attr_accessible :service, :uid, :token
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # A user can have multiple authentication providers (Google, facebook, etc.)
  embedded_in :user
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  validates_presence_of :service, :uid, :token
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
  #---------------------------------------------------------------------------
  #
  #
  ############################################################################
  # PROTECTED METHODS BLOCK
  ############################################################################
  #
  protected
  #
  #---------------------------------------------------------------------------
  #
  #
  ############################################################################
  # PRIVATE METHODS BLOCK
  ############################################################################
  #
  private
  #
  #---------------------------------------------------------------------------
  #
end
