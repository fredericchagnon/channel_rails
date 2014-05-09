##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Persona
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Validations
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  # A Persona belongs to categories defined in PERSONA_CATEGORIES global cstnt
  field :category, :type => String
  # A Persona has a name that is publically viewable
  field :public_name, :type => String
  # A Persona has a rank, which is used to determine which Persona takes
  # precedence if a User has multiple Personas (default is the first Persona
  # whose category is "personal")
  field :rank, :type => Integer, :default => 0
  # A Persona has a flag to determine whether the persona is Public (i.e. 
  # anybody and search and connect to this persona without having to be 
  # confirmed AND connections are one-sided); Normal (i.e. can be searched by
  # using the exact address or being part of 2nd degree circle and must be
  # confirmed by both sides to connect); Unlisted (i.e. not searchable)
  # The value of the public flag is inherited by the User's public_flag
  field :public_flag, :type => Integer, :default => 0
  # A Persona has the following user-entered attributes
  field :prefix, :type => String
  field :first_name, :type => String
  field :first_name_phonetic, :type => String
  field :middle_name, :type => String
  field :last_name, :type => String
  field :last_name_phonetic, :type => String
  field :suffix, :type => String
  field :nickname, :type => String
  field :job_title, :type => String
  field :department, :type => String
  field :company, :type => String
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  # Set accessible attributes
  attr_accessible :category, :public_name, :rank, :prefix, :first_name, 
    :first_name_phonetic, :middle_name, :last_name, :last_name_phonetic,
    :suffix, :nickname, :job_title, :department, :company
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # Reference relationships to other first order models
  embedded_in :user
  # Embed an avatar for each persona
  embeds_one :avatar, :cascade_callbacks => true
  accepts_nested_attributes_for :avatar, :allow_destroy => true
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # Require basic information to be always present
  validates_presence_of :category, :rank, :on => :create
  # Ensure category format is regularized (PERSonal => Personal)
  before_validation :strip_and_capitalize_category
  # Require aditional information to be present after update
  before_validation :ensure_at_least_one_name_present
  # Ensure that the Category is allowed
  validates :category, inclusion: {in: PERSONA_CATEGORIES}
  # Ensure that a Persona has a "rank" and that it is coherent
  # validate :ensure_coherent_rank_set, :on => :update
  # Ensure that the rank is an integer greater than 0
  validates_numericality_of :rank, :only_integer => true, :greater_than => 0
  # Ensure that the public_flag has a value that is allowed
  validates :public_flag, inclusion: {in: PUBLIC_FLAG_VALUES}
  # Ensure that the persona's public_flag is coherent with the user's
  validate :ensure_public_flag_consistent_with_user
  # Callback to update all persona handles on create & destroy actions
  before_create :create_persona_handles
  before_destroy :destroy_persona_handles, :destroy_avatar
  # Callback to set the default public name if the user hasn't set one
  before_save :assign_default_public_name
  # # Update indexes for search after updating element
  # after_update :update_fulltext_search_index
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
  # Callback Method to regularize category string
  def strip_and_capitalize_category
    if self.category.present?
      self.category.strip!
      self.category.capitalize!
    end
  end
  #
  # Callback Method to ensure that at least one name string is present
  def ensure_at_least_one_name_present
    if self.first_name.nil? and self.middle_name.nil? and self.last_name.nil?
      errors.add(:base, 'Persona is missing a name')
      return false
    end
  end
  #
  # Callback to ensure that the persona's public_flag is coherent with the
  # user's. 
  # Invalid combinations as follows:
  # 1) user.public_flag = PUBLIC    & persona.public_flag = UNLISTED
  # 1) user.public_flag = NORMAL    & persona.public_flag = PUBLIC
  # 1) user.public_flag = NORMAL    & persona.public_flag = UNLISTED
  # 1) user.public_flag = UNLISTED  & persona.public_flag = NORMAL
  # 1) user.public_flag = UNLISTED  & persona.public_flag = PUBLIC
  def ensure_public_flag_consistent_with_user
    if (self.user.public_flag ==  1 and self.public_flag == -1) or \
      (self.user.public_flag  ==  0 and self.public_flag ==  1) or \
      (self.user.public_flag  ==  0 and self.public_flag == -1) or \
      (self.user.public_flag  == -1 and self.public_flag ==  0) or \
      (self.user.public_flag  == -1 and self.public_flag ==  1)
      errors.add(:base, 'Incoherent public_flag value')
      return false
    end
  end
  #
  # Method to create new persona handles for a new persona
  def create_persona_handles
    self.user.statuses.each do |s|
      self.user.contact_handles.each do |c|
        c.protocols.active.each do |r|
          s.persona_handles.create(persona_id: self.id, protocol_id: r.id)
        end
      end
    end
  end
  #
  # Method to destroy persona handles when destroying a persona
  def destroy_persona_handles
    self.user.statuses.each do |s|
      s.persona_handles.where(persona_id: self.id).destroy_all
    end
  end
  #
  # Method to destroy avatar when destroying a persona
  def destroy_avatar
    unless self.avatar.nil?
      self.avatar.remove_asset!
    end
  end
  #
  # Callback to set the public_name to category if the user has not set one
  def assign_default_public_name
    self.public_name ||= self.category
  end
  #
  # # Callback to update the search index
  # def update_fulltext_search_index
  #   self.user.update_ngram_index
  # end
  #
end