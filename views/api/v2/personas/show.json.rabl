helper RablHelper
object @persona
node :id do |p|
  p.id.to_s
end
attributes :category, :public_name, :rank, :prefix, :first_name, 
  :first_name_phonetic, :middle_name, :last_name, :last_name_phonetic,
  :suffix, :nickname, :job_title, :department, :company
node :updated_at => :updated_at do |p|
  p.updated_at.to_f
end
node_unless_nil(:avatar) do
  node :id do |a|
    a.id.to_s
  end
  node :updated_at => :updated_at do |x|
    x.updated_at.to_f
  end
end
# node :id do |p|
#   p.id.to_s
# end
# attributes :category, :public_name, :rank, :prefix, :first_name, 
#   :first_name_phonetic, :middle_name, :last_name, :last_name_phonetic,
#   :suffix, :job_title, :department, :company

# child :avatar => :avatar do
#   attributes :id
# end
# child_unless_nil(:avatar) {:id, :updated_at}
# child_unless_nil(:avatar) do
#   # node :id do |a|
#   #   a.id.to_s
#   # end
#   attributes :id => :id, :updated_at_to_f => :updated_at
#   # node :updated_at => :updated_at do |x|
#   #   x.updated_at.to_f
#   # end
# end