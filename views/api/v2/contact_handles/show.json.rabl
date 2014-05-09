object @contact_handle => :contact_handle
node :id do |x|
  x.id.to_s
end
attributes :name, :country_name, :country_code, :value, :url
# attributes :id, :name, :country_name, :country_code, :value, :url
node :updated_at do |c|
  c.updated_at.to_f
end
child :protocols => :protocols do
  node :id do |x|
    x.id.to_s
  end
  attributes :type, :active
  # attributes :id, :type, :active
end