##############################################################################
#                                                                            #
#                    COPYRIGHT 2011 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Device
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Validations
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  # The unique identifier if the device
  field :unique_identifier, :type => String
  # The type of device
  field :url, :type => String
  # The device token (for push notifications) - only stored when the user
  # agrees to allow push notifications
  field :push_token, :type => String, :default => nil
  # The device setting for access to the local address book
  field :address_book_access, :type => Boolean, :default => false
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  # Setup accessible (or protected) attributes for your model
  attr_accessible :unique_identifier, :url, :push_token, :address_book_access
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # A user can operate from multiple devices
  embedded_in :user
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # Regularize URL
  before_validation :strip_url
  # Replace supplied URL with corresponding url from Contants
  before_validation :replace_url
  # Make sure that a Device has an identifier associated with it
  validates_presence_of :unique_identifier, :allow_blank => false
  # Make sure the device has a type/URL
  validates :url, presence: true, inclusion: {in: DEVICE_URLS}
  # Make sure the address_book_access is Boolean
  validates :address_book_access, inclusion: {in: [true, false]}
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
  # Method to regularize url format
  def strip_url
    if self.url.present?
      self.url.strip!
    end
  end
  # Method to replace url with one from constant array
  def replace_url
    if self.url.present?
      DEVICE_URLS.each do |u|
        if u.casecmp(self.url) == 0
          self.url = u
        end
      end
    end
  end
  #
  #
end
