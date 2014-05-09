object @notifications
child :incoming_requests => :incoming_requests do
 attributes :id, :from_id, :from_name, :from_persona_id
end
child :outgoing_requests => :outgoing_requests do
  attributes :id, :to_id, :to_name, :to_persona_id
end
child :incoming_from_suggests => :incoming_from_suggests do
  attributes :id, :other_id , :by_id, :other_name, :other_persona_id, :by_name, :by_persona_id
end
child :incoming_to_suggests => :incoming_to_suggests do
  attributes :id , :other_id, :by_id, :other_name, :other_persona_id, :by_name, :by_persona_id
end
child :outgoing_suggests => :outgoing_suggests do
  attributes :id, :from_id, :to_id, :from_name, :from_persona_id, :to_name, :to_persona_id
end
# helper RablHelper
# object false
# node_unless_nil(:incoming_requests) do
#   @incoming_requests.map { |ic| {:id => ic.id.to_s, :from_id => ic.from_id.to_s, :from_name => ic.from.primary_persona.first_name + " " + ic.from.primary_persona.last_name, :from_persona_id => ic.from.primary_persona.id.to_s} }
# end
# node_unless_nil(:outgoing_requests) do
#   @outgoing_requests.map { |oc| {:id => oc.id.to_s, :to_id => oc.to_id.to_s, :to_name => oc.to.primary_persona.first_name + " " + oc.to.primary_persona.last_name, :to_persona_id => oc.to.primary_persona.id.to_s} }
# end
# node_unless_nil(:incoming_from_suggests) do
#   @incoming_from_suggests.map { |oc| {:id => oc.id.to_s, :other_id => oc.to_id.to_s, :by_id => oc.by_id.to_s, :other_name => oc.to.primary_persona.first_name + " " + oc.to.primary_persona.last_name, :other_persona_id => oc.to.primary_persona.id.to_s, :by_name => oc.by.primary_persona.first_name + " " + oc.by.primary_persona.last_name, :by_persona_id => oc.by.primary_persona.id.to_s} }
# end
# node_unless_nil(:incoming_to_suggests) do
#   @incoming_to_suggests.map { |oc| {:id => oc.id.to_s, :other_id => oc.from_id.to_s, :by_id => oc.by_id.to_s, :other_name => oc.from.primary_persona.first_name + " " + oc.from.primary_persona.last_name, :other_persona_id => oc.from.primary_persona.id.to_s, :by_name => oc.by.primary_persona.first_name + " " + oc.by.primary_persona.last_name, :by_persona_id => oc.by.primary_persona.id.to_s} }
# end
# node_unless_nil(:outgoing_suggests) do
#   @outgoing_suggests.map { |oc| {:id => oc.id.to_s, :from_id => oc.from_id.to_s, :to_id => oc.to_id.to_s, :from_name => oc.from.primary_persona.first_name + " " + oc.from.primary_persona.last_name, :from_persona_id => oc.from.primary_persona.id.to_s, :to_name => oc.to.primary_persona.first_name + " " + oc.to.primary_persona.last_name, :to_persona_id => oc.to.primary_persona.id.to_s} }
# end
# unless @incoming_requests.empty?
#   node(:incoming_requests) do
#     @incoming_requests.map { |ic| {:id => ic.id.to_s, :from_id => ic.from_id.to_s, :from_name => ic.from.primary_persona.first_name + " " + ic.from.primary_persona.last_name, :from_persona_id => ic.from.primary_persona.id.to_s} }
#   end
# end
# unless @outgoing_requests.empty?
#   node(:outgoing_requests) do
#     @outgoing_requests.map { |oc| {:id => oc.id.to_s, :to_id => oc.to_id.to_s, :to_name => oc.to.primary_persona.first_name + " " + oc.to.primary_persona.last_name, :to_persona_id => oc.to.primary_persona.id.to_s} }
#   end
# end
# unless @incoming_from_suggests.empty?
#   node(:incoming_from_suggests) do
#     @incoming_from_suggests.map { |oc| {:id => oc.id.to_s, :other_id => oc.to_id.to_s, :by_id => oc.by_id.to_s, :other_name => oc.to.primary_persona.first_name + " " + oc.to.primary_persona.last_name, :other_persona_id => oc.to.primary_persona.id.to_s, :by_name => oc.by.primary_persona.first_name + " " + oc.by.primary_persona.last_name, :by_persona_id => oc.by.primary_persona.id.to_s} }
#   end
# end
# unless @incoming_to_suggests.empty?
#   node(:incoming_to_suggests) do
#     @incoming_to_suggests.map { |oc| {:id => oc.id.to_s, :other_id => oc.from_id.to_s, :by_id => oc.by_id.to_s, :other_name => oc.from.primary_persona.first_name + " " + oc.from.primary_persona.last_name, :other_persona_id => oc.from.primary_persona.id.to_s, :by_name => oc.by.primary_persona.first_name + " " + oc.by.primary_persona.last_name, :by_persona_id => oc.by.primary_persona.id.to_s} }
#   end
# end
# unless @outgoing_suggests.empty?
#   node(:outgoing_suggests) do
#     @outgoing_suggests.map { |oc| {:id => oc.id.to_s, :from_id => oc.from_id.to_s, :to_id => oc.to_id.to_s, :from_name => oc.from.primary_persona.first_name + " " + oc.from.primary_persona.last_name, :from_persona_id => oc.from.primary_persona.id.to_s, :to_name => oc.to.primary_persona.first_name + " " + oc.to.primary_persona.last_name, :to_persona_id => oc.to.primary_persona.id.to_s} }
#   end
# end

# object @notifications
# child(:incoming_requests) do
#  attributes :id, :from_id, :from_name, :from_persona_id
# end
# child(:outgoing_requests) do
#   attributes :id, :to_id, :to_name, :to_persona_id
# end
# child(:incoming_from_suggests) do
#   attributes :id, :other_id , :by_id, :other_name, :other_persona_id, :by_name, :by_persona_id
# end
# child(:incoming_to_suggests) do
#   attributes :id , :other_id, :by_id, :other_name, :other_persona_id, :by_name, :by_persona_id
# end
# child(:outgoing_suggests) do
#   attributes :id, :from_id, :to_id, :from_name, :from_persona_id, :to_name, :to_persona_id
# end

# object false
# child(@incoming_requests => :incoming_requests) do
#   node :id do |x|
#     x.id.to_s
#   end
#   node :from_id do |x|
#     x.from_id.to_s
#   end
#   # attributes :id, :from_id
#   glue :from do
#     node :from_name do |u| 
#       u.primary_persona.first_name + " " + u.primary_persona.last_name
#     end
#     node :from_persona_id do |u| 
#       u.primary_persona.id.to_s
#     end
#   end
# end
# child(@outgoing_requests => :outgoing_requests) do
#   node :id do |x|
#     x.id.to_s
#   end
#   node :to_id do |x|
#     x.to_id.to_s
#   end
#   # attributes :id, :to_id
#   glue :to do
#     node :to_name do |u| 
#       u.primary_persona.first_name + " " + u.primary_persona.last_name
#     end
#     node :to_persona_id do |u| 
#       u.primary_persona.id.to_s
#     end
#   end
# end
# child(@incoming_from_suggests => :incoming_from_suggests) do
#   node :id do |x|
#     x.id.to_s
#   end
#   node :other_id do |x|
#     x.to_id.to_s
#   end
#   node :by_id do |x|
#     x.by_id.to_s
#   end
#   # attributes :id => :id, :to_id => :other_id, :by_id => :by_id
#   glue :to do
#     node :other_name do |u| 
#       u.primary_persona.first_name + " " + u.primary_persona.last_name
#     end
#     node :other_persona_id do |u| 
#       u.primary_persona.id.to_s
#     end
#   end
#   glue :by do
#     node :by_name do |u| 
#       u.primary_persona.first_name + " " + u.primary_persona.last_name
#     end
#     node :by_persona_id do |u| 
#       u.primary_persona.id.to_s
#     end
#   end
# end
# child(@incoming_to_suggests => :incoming_to_suggests) do
#   node :id do |x|
#     x.id.to_s
#   end
#   node :other_id do |x|
#     x.from_id.to_s
#   end
#   node :by_id do |x|
#     x.by_id.to_s
#   end
#   # attributes :id => :id, :from_id => :other_id, :by_id => :by_id
#   glue :from do
#     node :other_name do |u| 
#       u.primary_persona.first_name + " " + u.primary_persona.last_name
#     end
#     node :other_persona_id do |u| 
#       u.primary_persona.id.to_s
#     end
#   end
#   glue :by do
#     node :by_name do |u| 
#       u.primary_persona.first_name + " " + u.primary_persona.last_name
#     end
#     node :by_persona_id do |u| 
#       u.primary_persona.id.to_s
#     end
#   end
# end
# child(@outgoing_suggests => :outgoing_suggests) do
#   node :id do |x|
#     x.id.to_s
#   end
#   node :from_id do |x|
#     x.from_id.to_s
#   end
#   node :to_id do |x|
#     x.to_id.to_s
#   end
#   # attributes :id, :from_id, :to_id
#   glue :from do
#     node :from_name do |u| 
#       u.primary_persona.first_name + " " + u.primary_persona.last_name
#     end
#     node :from_persona_id do |u| 
#       u.primary_persona.id.to_s
#     end
#   end
#   glue :to do
#     node :to_name do |u| 
#       u.primary_persona.first_name + " " + u.primary_persona.last_name
#     end
#     node :to_persona_id do |u| 
#       u.primary_persona.id.to_s
#     end
#   end
# end
