##############################################################################
#                                                                            #
#                    COPYRIGHT 2011 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Avatar
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Validations
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  field :filename, :type => String
  field :type, :type => String
  field :size, :type => String
  # field :uploaded_by, :type => String
  mount_uploader :asset, AvatarUploader
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  # Set accessible attributes
  attr_accessible :filename, :type, :size, :asset, :asset_cache, :asset_file
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # Reference relationships to other first order models
  embedded_in :persona
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # Avatar-related validations
  validates_presence_of   :asset
  validates_integrity_of  :asset
  validates_processing_of :asset
  # Callback to set image type and size
  # before_save :update_asset_attributes
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
  def updated_at_to_f
    updated_at.to_f
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
  # def update_asset_attributes
  #   if asset.present? && asset_changed?
  #     self.type = asset.file.content_type
  #     self.size = asset.file.size
  #   end
  # end
  #
end