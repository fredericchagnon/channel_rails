collection @contact_me_backs
node :id do |x|
  x.id.to_s
end
node :from_id do |x|
  x.from_id.to_s
end
# attributes :id, :from_id
node :updated_at do |cmb|
  cmb.updated_at.to_f
end
glue :from do
  node :name do |u| 
    u.primary_persona.first_name + " " + u.primary_persona.last_name
  end
end
