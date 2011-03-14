require_dependency 'issue'  

require 'dispatcher'   
 
# Patches Redmine's Issues dynamically. Adds a relationship
# Issue +has_many+ to ArchDecisionIssue
# Copied from dvandersluis' redmine_resources plugin: 
# http://github.com/dvandersluis/redmine_resources/blob/master/lib/resources_issue_patch.rb
module RedmineContacts
  module Patches    
    
    module IssuePatch
  
      def self.included(base) # :nodoc: 
    
        # base.extend(ClassMethods)
 
        # base.send(:include, InstanceMethods)
    
        # Same as typing in the class
        base.class_eval do    
          unloadable # Send unloadable so it will not be unloaded in development
          has_and_belongs_to_many :contacts, :order => "last_name, first_name", :uniq => true
        end  
      end  
    end  
    
    module TagPatch   
      module InstanceMethods    
        def color_name
          return "#" + "%06x" % self.color unless self.color.nil?
        end

        def assign_color
          self.color = (rand * 0xffffff)
        end
      end
  
      def self.included(base) # :nodoc: 
    
        # base.extend(ClassMethods)
 
        # base.send(:include, InstanceMethods)
    
        # Same as typing in the class    
        base.send :include, InstanceMethods
        
        base.class_eval do    
          before_save :assign_color
        end  
      end  
      
    end     
    
       

    module MailerPatch
      module ClassMethods
      end

      module InstanceMethods
        def note_added(note, parent)
          redmine_headers 'X-Project' => note.source.project.identifier, 
                          'X-Notable-Id' => note.source.id,
                          'X-Note-Id' => note.id
          message_id note
          if parent
            recipients (note.source.watcher_recipients + parent.watcher_recipients).uniq
          else
            recipients note.source.watcher_recipients
          end
        
          subject "[#{note.source.project.name}] - #{parent.name + ' - ' if parent}#{l(:label_note_for)} #{note.source.name}"  
      
          body :note => note,   
               :note_url => url_for(:controller => note.source.class.name.pluralize.downcase, :action => 'show', :project_id => note.source.project, :id => note.source.id)
          render_multipart('note_added', body)
        end
    
    def issue_connected(issue, contact)
      redmine_headers 'X-Project' => contact.projects.first.identifier, 
                      'X-Issue-Id' => issue.id,
                      'X-Contact-Id' => contact.id
      message_id contact
      recipients contact.watcher_recipients 
      subject "[#{contact.projects.first.name}] - #{l(:label_issue_for)} #{contact.name}"  
      
          body :contact => contact,
               :issue => issue,
               :contact_url => url_for(:controller => contact.class.name.pluralize.downcase, :action => 'show', :project_id => contact.project, :id => contact.id),
               :issue_url => url_for(:controller => "issues", :action => "show", :id => issue)
          render_multipart('issue_connected', body)
      
        end
    
      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end

Dispatcher.to_prepare do  

  unless Issue.included_modules.include?(RedmineContacts::Patches::IssuePatch)
    Issue.send(:include, RedmineContacts::Patches::IssuePatch)
  end

  unless Mailer.included_modules.include?(RedmineContacts::Patches::MailerPatch)
    Mailer.send(:include, RedmineContacts::Patches::MailerPatch)
  end   

  unless ActsAsTaggableOn::Tag.included_modules.include?(RedmineContacts::Patches::TagPatch)
    ActsAsTaggableOn::Tag.send(:include, RedmineContacts::Patches::TagPatch)
  end
  

  # Mailer.send(:include, MailerPatch) 
  # IssuesController.send(:include, ContactsIssuesControllerPatch)  
end

