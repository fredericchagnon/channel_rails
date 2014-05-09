##############################################################################
#                                                                            #
#                    COPYRIGHT 2011 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Post < ContactHandle
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  field :street_address, :type => String
  field :street_address_2, :type => String
  field :locality, :type => String # e.g. city
  field :region, :type => String # e.g. state or province
  field :postal_code, :type => String
  field :country_name, :type => String
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  attr_accessible :street_address, :street_address_2, :locality, :region, 
                  :postal_code, :country_name
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # RELATIONSHIPS ARE HANDLED BY THE CONTACT_HANDLE CLASS THAT POST INHERITS
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # Make sure the url is present and that its value is a chat-type
  validates :url, :presence => true, :inclusion => POST_URLS.collect{|x| x.downcase}
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
  #
end