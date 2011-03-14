
  map.connect 'projects/:project_id/deals/:action', :controller => 'deals'
  map.connect 'projects/:project_id/deals/:action/:id', :controller => 'deals'
  map.connect 'projects/:project_id/contacts/:action', :controller => 'contacts'
  map.connect 'projects/:project_id/contacts/:action/:id', :controller => 'contacts'

# 
# map.with_options :controller => 'contacts' do |contact_routes|
#   contact_routes.with_options :conditions => {:method => :get} do |contact_views|
#     contact_views.connect 'projects/:project_id/contacts', :action => 'index'
#     contact_views.connect 'projects/:project_id/contacts/new', :action => 'new'
#     contact_views.connect 'contacts/:id', :action => 'show'
#     contact_views.connect 'contacts/:id/edit', :action => 'edit'
#   end
#   contact_routes.with_options :conditions => {:method => :post} do |contact_actions|
#     contact_actions.connect 'projects/:project_id/contacts', :action => 'new'
#     contact_actions.connect 'contacts/:id/:action', :action => /destroy|edit/
#   end
# end
# 
