##############################################################################
#                                                                            #
#                    COPYRIGHT 2011 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Favorite
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Validations
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
  # Setup accessible (or protected) attributes for your model
  attr_accessible :connection_id
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # A user has multiple favorites
  embedded_in :user
  # A favorite references a connection 
  # (but we don't want connections to point to favorites)
  belongs_to :connection, :inverse_of => nil
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # Favorites are invalid unless the connection_id is populated
  validates_presence_of :connection_id, :allow_blank => false
  # We should also enforce the uniqueness of favorites for each 
  # user-connection pair
  validates_uniqueness_of :connection_id, :scope => :user_id
  # We should make sure that the connection is actively connected
  before_save :ensure_connection_id_valid, :ensure_connection_active
  # We should also make sure that favorites are only valid when the user
  # is a participant of the connection element
  before_save :ensure_user_owns_connection
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
  # Callback method to verify that the connection is active and connected
  def ensure_connection_id_valid
    if Connection.find(self.connection_id).nil?
      errors.add(:base, "Can't set an inexsitent connection as a favorite")
      return false
    end
  end
  #
  # Callback method to verify that the connection is active and connected
  def ensure_connection_active
    unless self.connection.connected?
      errors.add(:base, "Can't set an inactive connection as a favorite")
      return false
    end
  end
  #
  # Callback to make sure that the user owns the connection
  def ensure_user_owns_connection
    unless self.connection.owner?(self.user)
      errors.add(:base, "Can't set a connection you don't own as a favorite")
      return false
    end
  end
  #
end
