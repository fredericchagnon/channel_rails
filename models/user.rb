##############################################################################
#                                                                            #
#                    COPYRIGHT 2011 FADALABS, INC.                           #
#                                                                            #
##############################################################################
#
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Validations
  include Mongoid::FullTextSearch
  #
  ############################################################################
  # MONGO FIELD DECLARATIONS 
  ############################################################################
  #
  ## Database authenticatable
  field :email,              type: String
  field :encrypted_password, type: String

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Encryptable
  # field :password_salt, type: String

  ## Confirmable
  field :confirmation_token,   type: String
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  field :failed_attempts, type: Integer # Only if lock strategy is :failed_attempts
  field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  field :locked_at,       type: Time

  # Token authenticatable
  field :authentication_token, type: String
  
  # Temporary token for authentication with 3rd parties
  field :external_token, type: String, default: nil
  
  # Keep track of which device made the last changing call
  field :last_api_device_id, type: String
  
  # The current_status points to the Status ID that is active
  field :current_status, type: String
  # A User has a flag to determine whether it is Public (i.e. 
  # anybody and search and connect to this User without having to be 
  # confirmed AND connections are one-sided); Normal (i.e. can be searched by
  # using the exact address or being part of 2nd degree circle and must be
  # confirmed by both sides to connect); Unlisted (i.e. not searchable)
  # PUBLIC = 1; NORMAL = 0; UNLISTED = -1
  field :public_flag, type: Integer, default: 0
  #
  # Yeah, we're storing your facebook id - just so we can connect ppl together
  # since facebook doesn't allow us access to your friend's emails (just their ID)
  field :facebook_id, type: String, default: nil
  #
  # Add full-text search capability for email, only for normal
  # and public users
  # fulltext_search_in :email, :index_name => 'email_name_index', 
  #   :filters => { :is_searchable => lambda { |x| x.public_flag >= 0 } }
  def search_in_email
    self.map{ |u| u.email if u.public_flag >= 0 }.join(' ')
  end
  fulltext_search_in :search_in_email, :index_name => 'email_name_index', :reindex_immediately => true
  #
  # Add full-text search capability in the persona names, only for normal and
  # public personas
  def search_in_name
    personas.map{ |p| [p.first_name, p.last_name].join(' ') if p.public_flag >= 0 }.join(' ')
  end
  fulltext_search_in :search_in_name, :index_name => 'email_name_index', :reindex_immediately => true
  #  
  ############################################################################
  # GENERAL DESCRIPTION OF MODEL & ACCESSOR METHODS 
  ############################################################################
  #
  # This model holds the logic for the USER model, which is based on the
  # Devise gem and controls sign_up, login, etc.
  #
  # Include default devise modules. Others available are:
  # :rememberable, :encryptable, :timeoutable
  devise :async, :token_authenticatable, :database_authenticatable,
    :registerable, :confirmable, :recoverable, :trackable, 
    :validatable, :lockable, :omniauthable, :omniauth_providers => [:facebook, :google_apps]
  #
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :current_status, :password, :password_confirmation, 
    :remember_me, :last_api_device_id
  # The authentication token should never be set via mass assignment
  attr_protected :authentication_token
  #
  # Index
  index({ email: 1 }, { unique: true, background: true })
  #
  ############################################################################
  # RELATIONSHIPS TO OTHER MODELS 
  ############################################################################
  #
  # A user has multiple statuses
  embeds_many :statuses#, cascade_callbacks: true
  accepts_nested_attributes_for :statuses, :autosave => true
  # A has multiple personas
  embeds_many :personas
  accepts_nested_attributes_for :personas, :autosave => true
  # A user has many contact handles
  embeds_many :contact_handles#, cascade_callbacks: true
  accepts_nested_attributes_for :contact_handles, :autosave => true
  # A user can operate from multiple devices
  embeds_many :devices
  # A user can import contacts from multiple sources
  embeds_many :contact_imports
  # A user can have many favorite contacts
  embeds_many :favorites
  # A user can have multiple authentication providers (Google, facebook, etc.)
  embeds_many :authenticators
  # A user references and can be referenced by many queue elements
  has_and_belongs_to_many :connection_queues
  # A user can have many temporary connections
  has_many :temporary_connections, :dependent => :destroy
  #
  ############################################################################
  # MODEL CONDITIONS/CALLBACKS & VALIDATION RULES
  ############################################################################
  #
  # Ensure email format is regularized (Email@Domain.COM => email@domain.com)
  before_validation :strip_and_downcase_email
  # Ensure the presence and uniqueness of the user email
  validates_presence_of   :email, :allow_blank => false, :allow_nil => false
  validates_uniqueness_of :email, :case_sensitive => false
  validates_format_of :email, :message => I18n.t('email.invalid'), :with => RFC822::EMAIL
  # Ensure the uniqueness of the authentication token
  validates_uniqueness_of :authentication_token, :case_sensitive => true, :allow_blank => false, :allow_nil => true
  # Ensure that the public_flag has a value that is allowed
  validates :public_flag, presence: true, inclusion: {in: PUBLIC_FLAG_VALUES}
  # Ensure that the current_status is valid in that the user owns the status
  before_save :ensure_user_owns_current_status
  # Clean-up all connections associated with user before destroying the object
  before_destroy :destroy_associated_connections
  before_destroy :destroy_associated_contact_me_backs
  # Could handle the line below by cascading callbacks but weonly want to do
  # this on destroy to ensure that teh avatar files are removed from the
  # server
  before_destroy :destroy_embedded_personas
  #
  ############################################################################
  # SCOPE BLOCK
  ############################################################################
  #
  scope :searchable, any_of({public_flag: 1}, {public_flag: 0})
  #
  ############################################################################
  # PUBLIC METHODS BLOCK
  ############################################################################
  #
  public
  #
  #--------------------- METHOD THAT REGISTERS A NEW USER --------------------
  #
  def self.sign_up(params={})
    # Create a user object with the parameters that were passed in the JSON
    user = User.new(params[:user].select{|k,v| k=="email"}.merge({password: Devise.friendly_token[0,20]}))
    # Store the identifier, push_token and address_book_access
    user.devices.new(params[:user][:device])
    # Create contact handles
    unless params[:user][:contact_handles].nil?
      params[:user][:contact_handles].each {|c| user.contact_handles.new(c, URLCLASS_MAP[c[:url].downcase].constantize) }
      user.contact_handles.each do |c|
        (c.url.upcase+"_PROTOCOLS").constantize.each do |p|
          c.protocols.new(type: p)
        end
      end
    end
    # Create the default Personas
    PERSONA_CATEGORIES.each_index {|x| user.personas.new(params[:user][:persona].merge({category: PERSONA_CATEGORIES[x], public_name: PERSONA_CATEGORIES[x], rank:  x+1}))} 
    # Create the default Statuses
    DEFAULT_STATUSES.each_index {|x| user.statuses.new({name: DEFAULT_STATUSES[x], color: STATUS_COLORS[x]})}
    user.statuses.each do |s|
      user.personas.each do |p|
        user.contact_handles.each do |c|
          c.protocols.each do |r|
              s.persona_handles.new(persona_id: p.id, protocol_id: r.id)
          end
        end
      end
    end
    # # Create contact handles
    # unless params[:user][:contact_handles].nil?
    #   params[:user][:contact_handles].each {|c| user.contact_handles.create!(c, URLCLASS_MAP[c[:url].downcase].constantize) }
    # end
    # # Create the default Personas
    # PERSONA_CATEGORIES.each_index {|x| user.personas.create!(params[:user][:persona].merge({category: PERSONA_CATEGORIES[x], public_name: PERSONA_CATEGORIES[x], rank:  x+1}))} 
    # # Create the default Statuses
    # DEFAULT_STATUSES.each_index {|x| user.statuses.create!({name: DEFAULT_STATUSES[x], color: STATUS_COLORS[x]})}
    # Create the authentication token if the user params were good
    user.ensure_authentication_token
    # Assign the current status
    user.update_attributes(current_status: user.statuses.first.id)
    return user if user.save


    # # Create a user object with the parameters that were passed in the JSON
    # user = User.create(params[:user].select{|k,v| k=="email"}.merge({password: Devise.friendly_token[0,20]}))
    # # Store the identifier, push_token and address_book_access
    # user.devices.create(params[:user][:device])
    # # Create contact handles
    # unless params[:user][:contact_handles].nil?
    #   params[:user][:contact_handles].each {|c| user.contact_handles.create(c, URLCLASS_MAP[c[:url].downcase].constantize) }
    # end
    # # Create the default Personas
    # PERSONA_CATEGORIES.each_index {|x| user.personas.create(params[:user][:persona].merge({category: PERSONA_CATEGORIES[x], public_name: PERSONA_CATEGORIES[x], rank:  x+1}))} 
    # # Create the default Statuses
    # DEFAULT_STATUSES.each_index {|x| user.statuses.create({name: DEFAULT_STATUSES[x], color: STATUS_COLORS[x]})}
    # # # Create contact handles
    # # unless params[:user][:contact_handles].nil?
    # #   params[:user][:contact_handles].each {|c| user.contact_handles.create!(c, URLCLASS_MAP[c[:url].downcase].constantize) }
    # # end
    # # # Create the default Personas
    # # PERSONA_CATEGORIES.each_index {|x| user.personas.create!(params[:user][:persona].merge({category: PERSONA_CATEGORIES[x], public_name: PERSONA_CATEGORIES[x], rank:  x+1}))} 
    # # # Create the default Statuses
    # # DEFAULT_STATUSES.each_index {|x| user.statuses.create!({name: DEFAULT_STATUSES[x], color: STATUS_COLORS[x]})}
    # # Create the authentication token if the user params were good
    # user.ensure_authentication_token
    # # Assign the current status
    # user.update_attributes(current_status: user.statuses.first.id)
    # return user if user.save
  end
  #
  #------------------------ METHOD THAT LOG A USER IN ------------------------
  #
  def sign_in(params={})
    self.reset_authentication_token! if self.authentication_token.nil?
    self.devices.find_or_create_by(unique_identifier: params[:unique_identifier]).update_attributes(params)
  end
  #
  #----------------- METHOD THAT AUTHENTICATES A USER ------------------------
  #
  # Method to authenticate an API call
  def self.authenticate_api_call(uid, authtkn, did)
    # Catch errors in the arguments
    return :bad_request if uid.blank? or authtkn.blank? or did.blank?
    # Fetch the user object with the parameters that were passed in the JSON
    u = User.find(uid)
    # Check if the user exists
    if u.nil?
      return :unauthorized
    # Check that the existing token is valid and matches the supplied token
    # and that the calling device is active
    elsif u.authentication_token.nil? or u.authentication_token != authtkn or \
      u.devices.where(unique_identifier: did).empty?
      return :unauthorized
    elsif u.authentication_token == authtkn
      return u
    end
  end
  #
  #------------- METHOD THAT AUTHENTICATES A POST-OAUTH API CALL -------------
  #
  def self.authenticate_oauth(params={})
    user = User.where(email: params[:email]).first
    unless user.nil? or user.authenticators.where(token: params[:token]).empty?
      return user
    end
    return nil
  end
  # 
  #----------------- FACEBOOK OMNIAUTH - GET THE USER ------------------------
  #
  def self.oauthicate(params, signed_in_resource=nil)
    # logger.debug("oauth token is #{params['credentials']['token']}")
  	if params['provider'] == 'facebook'
	  	token = params['credentials']['token']
	  else
 		  token =	rand(36**100).to_s(36)
	  end	
    # This checks to see if the user already exists in the system - only
    # problem is that if user signed-up with different email than FB email...
    # Will have to have a "merge accounts" method & interface to deal with 
    # this edge case
    if user = User.where(email: params['info']['email']).first
      user.authenticators.find_or_create_by(:service => params['provider'], :uid => params['uid']).update_attributes(token: token)
      # return user
    else
      user = User.new({email: params['info']['email'], password: Devise.friendly_token[0,20]})
      # Populate the appropriate information in Authenticator
      user.authenticators.new(:service => params['provider'], :uid => params['uid'], :token => token)
      # Create a contact handle for the registration email
      user.contact_handles.new({url: "email", name: "Email", value: params['info']['email']}, Email)
      user.contact_handles.each do |c|
        (c.url.upcase+"_PROTOCOLS").constantize.each do |p|
          c.protocols.new(type: p)
        end
      end
      # Create the default Personas
      PERSONA_CATEGORIES.each_index {|x| user.personas.new({first_name: params['info']['first_name'], last_name: params['info']['last_name'], category: PERSONA_CATEGORIES[x], public_name: PERSONA_CATEGORIES[x], rank:  x+1})} 
      # Create the default Statuses
      DEFAULT_STATUSES.each_index {|x| user.statuses.new({name: DEFAULT_STATUSES[x], color: STATUS_COLORS[x]})}
      user.statuses.each do |s|
        user.personas.each do |p|
          user.contact_handles.each do |c|
            c.protocols.each do |r|
                s.persona_handles.new(persona_id: p.id, protocol_id: r.id)
            end
          end
        end
      end
      # Assign the current status
      user.update_attributes(current_status: user.statuses.first.id)
      # return user if user.save
    end
    # Populate the avatar for the personal ME with the facebook profile pic
    user.set_category_avatar_from_url("Home", params['info']['image'])
    # Populate the user's facebook_id for contact imports matching
  	if params['provider'] == 'facebook'
      user.update_attribute(:facebook_id, params['uid'])
    end
    #       user = User.create({email: params['info']['email'], password: Devise.friendly_token[0,20]})
    #       # Populate the appropriate information in Authenticator
    #       user.authenticators.create(:service => params['provider'], :uid => params['uid'], :token => token)
    #       # Create a contact handle for the registration email
    #       user.contact_handles.create({url: "email", name: "Email", value: params['info']['email']}, Email)
    #       # Create the default Personas
    #       PERSONA_CATEGORIES.each_index {|x| user.personas.create!({first_name: params['info']['first_name'], last_name: params['info']['last_name'], category: PERSONA_CATEGORIES[x], public_name: PERSONA_CATEGORIES[x], rank:  x+1})} 
    #       # Create the default Statuses
    #       DEFAULT_STATUSES.each_index {|x| user.statuses.create!({name: DEFAULT_STATUSES[x], color: STATUS_COLORS[x]})}
    #       # Assign the current status
    #       user.update_attributes(current_status: user.statuses.first.id)
    #       # return user if user.save
    #     end
    #     # Populate the avatar for the personal ME with the facebook profile pic
    #     user.set_category_avatar_from_url("Home", params['info']['image'])
    #     # Populate the user's facebook_id for contact imports matching
    # if params['provider'] == 'facebook'
    #       user.update_attribute(:facebook_id, params['uid'])
    #     end
    return user if user.save
  end
  # 
  #-------- METHOD TO SET AVATAR FOR PERSONAS OF A CATIRY FROM A URL ---------
  #
  def set_category_avatar_from_url(category, url)
    unless url.nil?
      self.personas.where(category: category).each do |p|
        if p.avatar.nil?
          pers_avatar = Avatar.new
          pers_avatar.remote_asset_url = url
          p.avatar = pers_avatar
          p.save
          sleep(2.seconds)
        end
      end
    end
  end  
  #
  #------------- METHOD THAT RETURNS HIGHEST USER'S RANKED PERSONA -----------
  #
  def primary_persona
    self.personas.asc(:rank).first
  end
  #
  #----------- METHOD THAT RETURNS NOTIFICATIONS FROM USER/CONNECTION ---------
  #
  def notifications(params={})
    result = OpenStruct.new
    result.incoming_requests = []
    Connection.to_user(self).conn_pending.each do |ic|
      result.incoming_requests << OpenStruct.new(:id => ic.id.to_s, :from_id => ic.from_id.to_s, :from_name => ic.from.primary_persona.first_name.to_s + " " + ic.from.primary_persona.last_name.to_s, :from_persona_id => ic.from.primary_persona.id.to_s)
    end
    result.outgoing_requests = []
    Connection.from_user(self).conn_pending.each do |oc|
      result.outgoing_requests << OpenStruct.new(:id => oc.id.to_s, :to_id => oc.to_id.to_s, :to_name => oc.to.primary_persona.first_name.to_s + " " + oc.to.primary_persona.last_name.to_s, :to_persona_id => oc.to.primary_persona.id.to_s)
    end
    result.incoming_from_suggests = []
    Connection.all_of(from_id: self.id, from_status: Connection::PENDING).each do |oc|
      result.incoming_from_suggests << OpenStruct.new(:id => oc.id.to_s, :other_id => oc.to_id.to_s, :by_id => oc.by_id.to_s, :other_name => oc.to.primary_persona.first_name.to_s + " " + oc.to.primary_persona.last_name.to_s, :other_persona_id => oc.to.primary_persona.id.to_s, :by_name => oc.by.primary_persona.first_name.to_s + " " + oc.by.primary_persona.last_name.to_s, :by_persona_id => oc.by.primary_persona.id.to_s)
    end
    result.incoming_to_suggests = []
    Connection.all_of(to_id: self.id, to_status: Connection::PENDING).excludes(from_status: Connection::REQUESTED).each do |oc|
      result.incoming_to_suggests << OpenStruct.new(:id => oc.id.to_s, :other_id => oc.from_id.to_s, :by_id => oc.by_id.to_s, :other_name => oc.from.primary_persona.first_name.to_s + " " + oc.from.primary_persona.last_name.to_s, :other_persona_id => oc.from.primary_persona.id.to_s, :by_name => oc.by.primary_persona.first_name.to_s + " " + oc.by.primary_persona.last_name.to_s, :by_persona_id => oc.by.primary_persona.id.to_s)
    end
    result.outgoing_suggests = []
    Connection.by_user(self).sugg_all_pending.each do |oc|
      result.outgoing_suggests << OpenStruct.new(:id => oc.id.to_s, :from_id => oc.from_id.to_s, :to_id => oc.to_id.to_s, :from_name => oc.from.primary_persona.first_name.to_s + " " + oc.from.primary_persona.last_name.to_s, :from_persona_id => oc.from.primary_persona.id.to_s, :to_name => oc.to.primary_persona.first_name.to_s + " " + oc.to.primary_persona.last_name.to_s, :to_persona_id => oc.to.primary_persona.id.to_s)
    end
    return result
  end
  #
  #------------- METHOD THAT PREPARES A USER'S CONTACT INFORMATION -----------
  #
  def contact_info(category, personas)
    protocols=[]
    mes = self.personas.where(category: category).asc(:rank).find(personas)
    mes.each do |p|
      unless self.current_status.nil?
        # Fetch all the PersonaHandles for the active status for one persona
        self.statuses.find(self.current_status).persona_handles.enabled.where(persona_id: p.id).asc(:rank).each do |ph|
          # Get the enabled protocols and their rank through the contact handles
          protocols << self.contact_handles.where("protocols._id" => ph.protocol_id).first.protocols.find(ph.protocol_id)
        end
      end
    end
    result = OpenStruct.new
    # result.avatar = nil
    result.avatar = OpenStruct.new
    result.contact_handles = []
    p = mes.first
    unless p.nil?
      result.id = p.id
      result.prefix = p.prefix
      result.first_name = p.first_name
      result.first_name_phonetic = p.first_name_phonetic
      result.middle_name = p.middle_name 
      result.last_name = p.last_name
      result.last_name_phonetic = p.last_name_phonetic
      result.suffix = p.suffix
      result.job_title = p.job_title
      result.department = p.department
      result.company = p.company
      a = OpenStruct.new
      if p.avatar.nil?
        a.id = nil
        a.updated_at = nil
        result.avatar = a
      else
        a.id = p.avatar.id
        a.user_id = p.user.id
        a.persona_id = p.id
        a.updated_at = p.updated_at
        result.avatar = a
      end
      protocols.uniq.each do |x|
        c = OpenStruct.new
        c.id = x.contact_handle.id
        c.url = x.contact_handle.url
        c.name = x.contact_handle.name
        c.country_code = x.contact_handle.country_code
        c.value = x.contact_handle.value
        c.protocol_id = x.id
        c.type = x.type
        result.contact_handles << c
      end
    end
    return result
  end
  #
  #-------------- METHOD THAT SEARCHES ACROSS USERS & PERSONAS ---------------
  #
  def self.search(search_string)
    search_string = search_string.strip.downcase
    # Check to see if the search string is an email -> return only one result
    if search_string =~ RFC822::EMAIL
      # Include private accounts
      srch = User.where(email: search_string).first
    else
      srch = User.fulltext_search(search_string, :index => 'email_name_index', :max_results => 25 )
      return srch.uniq
    end
  end
  #
  #------------- METHOD THAT IMPORTS AN ARRAY OF EMAILS INTO QUEUE -----------
  #
  def import(array=[])
    return false if (array.class != Array)# or array.empty?
    array.each do |e|
      # We're commingling the queue with facebook ID since we can't obtain email addresses
      if e.has_key?(:email)
        # Get verified email contact handles that matches
        email = e[:email].strip.downcase
        u = User.where("contact_handles.value" => email).first
      elsif e.has_key?(:facebook_id)
        # Get user with the same facebook id
        email = e[:facebook_id]+"@facebook.channel-app.com"
        u = User.where(facebook_id: e[:facebook_id]).first
      end
      # If a registered user has verified that email
      if u.nil?#or u.contact_handles.verified.where(value: e[:email].strip.downcase).empty?
        ConnectionQueue.add(self, email)
      else
        Connection.unqueue(self, u)
      end
    end
    #  return true below to give an all clear signal to api caller even if some emails weren't imported
    return true
  end
  #
  #---------------- METHOD THAT CONNECTS TWO PEOPLE IN PERSON ----------------
  #
  def in_person(params={})
    tc = TemporaryConnection.where(token: params[:token]).first
    if tc.nil?
      # tc = self.temporary_connections.create({token: params[:token], personas: params[:personas]})
      tc = self.temporary_connections.create({token: params[:token]})
    else
      c = Connection.connection(tc.user, self)
      if c.nil?
        Connection.create({from_id: tc.user.id, to_id: self.id, by_id: tc.user.id,  
          from_status: Connection::PENDING, to_status: Connection::PENDING, queue: true})
        # Connection.create({from_id: tc.user.id, to_id: self.id, by_id: tc.user.id, 
        #   from_persona_ids: tc.personas, to_persona_ids: params[:personas], 
        #   from_status: Connection::ACCEPTED, to_status: Connection::ACCEPTED})
      end
      tc.destroy
    end
  end
  #
  ############################################################################
  # PROTECTED METHODS BLOCK
  ############################################################################
  #
  protected
  #
  # Method to set/generate authentication token for a user
  def ensure_authentication_token! 
    reset_authentication_token! if authentication_token.blank? 
  end
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
  def strip_and_downcase_email
    if self.email.present?
      self.email.strip!
      self.email.downcase!
    end
  end
  #
  # Method to check that the current status belongs to the user
  def ensure_user_owns_current_status
    unless self.current_status.nil?
      unless self.statuses.collect{|x| x.id.to_s}.include?(self.current_status)
        errors.add(:base, 'user does not own current status')
        return false
      end
    end
  end
  #
  # Method to destroy associated connections
  def destroy_associated_connections
    Connection.from_user(self).destroy_all
    Connection.to_user(self).destroy_all
  end
  #
  # Method to destroy associated contact me back requests
  def destroy_associated_contact_me_backs
    ContactMeBack.from_owner(self).destroy_all
    ContactMeBack.to_owner(self).destroy_all
  end
  #
  # Method to destroy embedded personas (mostly to make sure the avatar files 
  # are removed from the server upon user destruction)
  def destroy_embedded_personas
    self.personas.destroy_all
  end
  #
  #---------------------------------------------------------------------------
  #
end
