object @cntct
node :connection_id do |c|
  c.connection_id.to_s
end
node :user_id do |c|
  c.user_id.to_s
end
node :my_personas do |c|
  c.my_personas.collect {|x| x.to_s}
end
node :favorite do |c|
  c.favorite
end
# attributes :connection_id, :my_personas, :user_id
child :home_me => :home_me do
  node :id do |x|
    x.id.to_s
  end
  attributes :prefix, :first_name, :first_name_phonetic, :middle_name, 
    :last_name, :last_name_phonetic, :suffix, :job_title, :department, :company
  child :contact_handles => :contact_handles do
    node :id do |x|
      x.id.to_s
    end
    node :protocol_id do |x|
      x.protocol_id.to_s
    end
    attributes :url, :type, :name, :country_code, :value
    # attributes :id, :url, :protocol_id, :type, :name, :value
  end
  child :avatar => :avatar do
    node :id do |y|
      y.id.to_s
    end
    node :user_id do |y|
      y.user_id.to_s
    end
    node :persona_id do |y|
      y.persona_id.to_s
    end
    # attributes :id, :user_id, :persona_id
    node :updated_at do |a|
      a.updated_at.to_f
    end
  end
end
child :work_me => :work_me do
  node :id do |x|
    x.id.to_s
  end
  attributes :prefix, :first_name, :first_name_phonetic, :middle_name, 
    :last_name, :last_name_phonetic, :suffix, :job_title, :department, :company
  child :contact_handles => :contact_handles do
    node :id do |x|
      x.id.to_s
    end
    node :protocol_id do |x|
      x.protocol_id.to_s
    end
    attributes :url, :type, :name, :country_code, :value
    # attributes :id, :url, :protocol_id, :type, :name, :value
  end
  child :avatar => :avatar do
    node :id do |y|
      y.id.to_s
    end
    node :user_id do |y|
      y.user_id.to_s
    end
    node :persona_id do |y|
      y.persona_id.to_s
    end
    # attributes :id, :user_id, :persona_id
    node :updated_at do |a|
      a.updated_at.to_f
    end
    
  end
end
