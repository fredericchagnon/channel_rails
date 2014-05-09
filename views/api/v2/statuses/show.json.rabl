object @status
node :id do |s|
  s.id.to_s
end
attributes :name, :color
# attributes :id, :name, :color
node :updated_at do |s|
  s.updated_at.to_f
end
child :persona_handles => :persona_handles do
  node :id do |p|
    p.id.to_s
  end
  node :persona_id do |p|
    p.persona_id.to_s
  end
  node :protocol_id do |p|
    p.protocol_id.to_s
  end
  # node :contact_handle_id do |p|
  #   p.contact_handle_id.to_s
  # end
	attributes :rank, :enabled
  # attributes :id, :rank, :enabled, :persona_id, :protocol_id, :contact_handle_id
end