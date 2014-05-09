##############################################################################
#                                                                            #
#                    COPYRIGHT 2011 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class ContactImport
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Validations
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  # The source of imported contacts
  field :source, :type => String
  # The version of the source
  field :version, :type => String
  # Keep the authentication token in memory 
  field :auth_token, :type => String
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  # Setup accessible (or protected) attributes for your model
  attr_accessible :source, :version, :auth_token
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # A user can import contacts from multiple sources (Gmail, Facebook)
  embedded_in :user
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # Make sure the doc has a source
  validates :source, presence: true, inclusion: {in: CONTACT_IMPORT_SOURCES}
  # Make sure the address_book_access is Boolean
  validates :version, presence: true
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
  #
end
