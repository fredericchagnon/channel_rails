##############################################################################
#                                                                            #
#                    COPYRIGHT 2012 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class Status
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Validations
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  # Each status has a name
  field :name, :type => String
  # Status color
  field :color, :type => String
  #
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  # Set accessible attributes
  attr_accessible :name, :color, :persona_handles_attributes
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # A status belongs to a user
  embedded_in :user
  # A Status references many persona_handles, each with its rank
  embeds_many :persona_handles#, cascade_callbacks: true
  accepts_nested_attributes_for :persona_handles, :autosave => true
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # Ensure name format is regularized
  before_validation :strip_name
  # Require basic information
  validates_presence_of :name
  # Ensure that the status name is unique for the user
  validates_uniqueness_of :name, :scope => :color
  # Ensure that a status is associated to a user before saving it (no orphans)
  before_save :ensure_status_associated_to_user
  # Ensure that the Status Color is allowed
  validates :color, :inclusion => STATUS_COLORS
  # Callback to re-rank all the persona_handles (to prevent runaway ranking)
  # after_save :re_rank_status_persona_handles
  # Ensure that the status is always properly populated
  after_save :reform_status, :re_rank_status_persona_handles
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
  # Callback Method to regularize name string
  def strip_name
    if self.name.present?
      self.name.strip!
    end
  end
  #
  # Callback Method to ensure that the Status isn't orphaned
  def ensure_status_associated_to_user
    # Check that the Status belongs to a user
    if self.user.nil?
      errors.add(:base, 'Status not associated with a User')
      return false
    end
  end
  #
  # Method to ensure that status always well formed
  def reform_status
    self.user.personas.each do |p|
      self.user.contact_handles.each do |c|
        c.protocols.each do |r|
          if self.persona_handles.where(persona_id: p.id, protocol_id: r.id).first.nil?
            self.persona_handles.create(persona_id: p.id, protocol_id: r.id) if r.active?
          elsif self.persona_handles.where(persona_id: p.id, protocol_id: r.id).first.nil? == false
            self.persona_handles.where(persona_id: p.id, protocol_id: r.id).destroy_all if r.inactive?
          end
        end
      end
    end
  end
  #
  # Callback method to ensure that the persona_handle ranks start at 1 and 
  # increment by values of 1
  def re_rank_status_persona_handles
    # Ranks are persona-specific
    self.user.personas.each do |p|
      enabled = self.persona_handles.enabled.where(persona_id: p.id).asc(:rank).collect {|x| {"id" => x.id, "rank" => self.persona_handles.enabled.where(persona_id: p.id).asc(:rank).to_a.index(x)+1}}
      disabled = self.persona_handles.disabled.where(persona_id: p.id).asc(:rank).collect {|x| {"id" => x.id, "rank" => self.persona_handles.disabled.where(persona_id: p.id).asc(:rank).to_a.index(x)+enabled.size+1}}
      self.attributes = {persona_handles_attributes: enabled + disabled}
      # Start by ranking the enabled persona_handles
      # temp_rank = 0
      # self.update_attributes({persona_handles_attributes: enabled + disabled})
      # # Start by ranking the enabled persona_handles
      # self.persona_handles.where(persona_id: p.id, enabled: true).asc(:rank).each do |ph|
      #   temp_rank += 1
      #   ph.update_attributes({id: ph.id, rank: temp_rank})
      # end
      # # then rank the disabled persona_handles after the enabled ones
      # self.persona_handles.where(persona_id: p.id, enabled: false).asc(:rank).each do |ph|
      #   temp_rank += 1
      #   ph.update_attributes({id: ph.id, rank: temp_rank})
      # end
    end
  end
  #
  #
end