##############################################################################
#                                                                            #
#                    COPYRIGHT 2011 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Email < ContactHandle
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # RELATIONSHIPS ARE HANDLED BY THE CONTACT_HANDLE CLASS THAT EMAIL INHERITS
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # # Set the appropriate URL for this contact handle type
  # after_initialize :set_url_to_email
  # Make sure the url is present and that its value is a phone-type
  validates :url, :presence => true, :inclusion => EMAIL_URLS.collect{|x| x.downcase}
  # Regularize email format
  before_validation :strip_and_downcase_value
  # Validate email address
  validates_format_of :value, :message => I18n.t('email.invalid'),
    :with => RFC822::EMAIL
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
  # Method to regularize email format
  def strip_and_downcase_value
    if self.value.present?
      self.value.strip!
      self.value.downcase!
    end
  end
  #
end