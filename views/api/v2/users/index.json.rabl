collection @users
node :id do |u|
  u.id.to_s
end
attributes :email
# attributes :id, :email
glue :primary_persona do
  node :name do |p|
    p.first_name.to_s + " " + p.last_name.to_s
  end
  node :persona_id do |p|
    p.id.to_s
  end
end
