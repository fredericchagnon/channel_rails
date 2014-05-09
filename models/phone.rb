##############################################################################
#                                                                            #
#                    COPYRIGHT 2011 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Phone < ContactHandle
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  # Each phone number has a country code & we also store country name to
  # handle special cases (e.g., Canada and US both have +1 CC)
  field :country_name, type: String, default: "US"
  field :country_code, type: String, default: "+1"
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  attr_accessible :country_name, :country_code
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # RELATIONSHIPS ARE HANDLED BY THE CONTACT_HANDLE CLASS THAT IPHONE INHERITS
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # Make sure the url is present and that its value is a phone-type
  validates :url, presence: true, inclusion: PHONE_URLS.collect{|x| x.downcase}
  validates :country_name, presence: true, inclusion: COUNTRY_NAMES_MAP.collect{|k,v| k}
  validates :country_code, presence: true, inclusion: COUNTRY_CODES_MAP.collect{|k,v| k}
  # SHOULD PROBABLY HAVE A CALLBACK THAT REGULARIZES THE PHONE NUMBER FORMAT
  before_validation :strip_number_and_remove_country_code
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
  def strip_number_and_remove_country_code
    # remove all non digit characters
    self.value.gsub!(/\D/i,'')
    # remove the country code form the number in case it's there
    if self.value.start_with?(self.country_code.gsub('+',''))
      self.value.slice!(0,self.country_code.gsub('+','').length)
    end
  end
  #
end