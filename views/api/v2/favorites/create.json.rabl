object @favorite
node :id do |x|
  x.id.to_s
end
node :connection_id do |x|
  x.connection_id.to_s
end
# attributes :id, :connection_id
node :updated_at do |f|
  f.updated_at.to_f
end
