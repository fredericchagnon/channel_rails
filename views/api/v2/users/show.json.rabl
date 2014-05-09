object @current_user
node :id do |u|
  u.id.to_s
end
attributes :email, :authentication_token, :current_status
# attributes :id, :email, :authentication_token, :current_status
node :updated_at do |u|
  u.updated_at.to_f
end
child :personas => :personas do
	extends "api/v2/personas/index"
end
child :contact_handles => :contact_handles do
	extends "api/v2/contact_handles/index"
end
child :statuses => :statuses do
	extends "api/v2/statuses/index"
end
child :favorites => :favorites do
	extends "api/v2/favorites/index"
end
