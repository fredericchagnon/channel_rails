object @notification
node :id do |r|
  r.id.to_s
end
node :from_id do |s|
  s.from_id.to_s
end
node :to_id do |s|
  s.to_id.to_s
end
node :by_id do |s|
  s.by_id.to_s
end
node :from_persona_ids do |s|
  s.from_persona_ids.collect {|x| x.to_s}
end
node :to_persona_ids do |s|
  s.to_persona_ids.collect {|x| x.to_s}
end
# attributes :id, :from_id, :to_id, :by_id, :from_persona_ids, :to_persona_ids
