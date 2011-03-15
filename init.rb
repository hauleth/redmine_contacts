# Redmine contact plugin

config.gem "acts-as-taggable-on", :version => '2.0.6'

require 'redmine'    
require 'redmine_contacts/patches/contacts_issue_patch'
require 'redmine_contacts/wiki_macros/contacts_wiki_macros'  
require 'redmine_contacts/hooks/show_issue_contacts_hook'       

RAILS_DEFAULT_LOGGER.info 'Starting Contact plugin for Redmine'

Redmine::Plugin.register :contacts do
  name 'Contacts plugin'
  author 'Łukasz Niemier'
  description 'This is a plugin for Redmine that can be used to track basic contacts information'
  version '0.1.0'

  requires_redmine :version_or_higher => '0.9.0'   
  
  project_module :contacts_module do
    permission :view_contacts, :contacts => [:show, 
                                             :index, 
                                             :live_search, 
                                             :contacts_notes, 
                                             :contacts_issues], :public => true
    permission :edit_contacts, :contacts => [:edit, 
                                               :update, 
                                               :new, 
                                               :create, 
                                               :add_attachment, 
                                               :add_note, 
                                               :destroy_note, 
                                               :edit_tags,
                                               :add_task, 
                                               :add_contact_to_issue,
                                               :add_contact_to_project, 
                                               :close_issue,
                                               :delete_own_notes]   
    permission :add_notes, :contacts =>  [:add_note, :delete_own_notes], :deals => [:add_note]                                        
    permission :delete_contacts, :contacts => [:destroy, 
                                               :destroy_contact_from_issue]
    permission :delete_deals, :deals => :destroy    
    
    permission :view_deals, :deals => [:index, :show], :public => true
    permission :edit_deals, :deals => [:new, 
                                       :create, 
                                       :edit, 
                                       :update,
                                       :add_attachment,
                                       :add_note,
                                       :destroy_note], :public => true
    
  end

  menu :project_menu, :contacts, {:controller => 'contacts', :action => 'index'}, :caption => :contacts_title, :param => :project_id
  # menu :project_menu, :deals, { :controller => 'deals', :action => 'index' }, :caption => :label_deal_plural, :param => :project_id
  
  menu :top_menu, :contacts, {:controller => 'contacts', :action => 'index'}, :caption => :contacts_title
  
  activity_provider :contacts, :default => false, :class_name => ['Note']  

  # activity_provider :contacts, :default => false   
end

