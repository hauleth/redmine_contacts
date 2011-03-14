class Note < ActiveRecord::Base   
  unloadable
  
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :source, :polymorphic => true
  
  validates_presence_of :source, :author, :content

  
  after_create :send_mails  
  
  acts_as_attachable :view_permission => :view_contacts,  
                     :delete_permission => :edit_contacts   
                    
  acts_as_event :title => Proc.new {|o| "#{l(:label_note_for)}: #{o.source.name}"}, 
                :type => "issue-note", 
                :url => Proc.new {|o| {:controller => o.source.class.name.pluralize.downcase, :action => 'show', :project_id => o.source.project, :id => o.source.id }},
                :description => Proc.new {|o| o.content}      
                                   
  acts_as_activity_provider :type => 'contacts',               
                            :permission => :view_contacts,  
                            :author_key => :author_id,
                            :find_options => {:select => "#{Note.table_name}.*", 
                            :joins => "LEFT JOIN #{Contact.table_name} ON #{Note.table_name}.source_type='Contact' AND #{Contact.table_name}.id = #{Note.table_name}.source_id " +
                                      "LEFT JOIN #{Project.table_name} ON #{Contact.table_name}.project_id = #{Project.table_name}.id"}    
                                                               
  acts_as_activity_provider :type => 'deals',               
                            :permission => :view_deals,  
                            :author_key => :author_id,
                            :find_options => {:select => "#{Note.table_name}.*", 
                            :joins => "LEFT JOIN #{Deal.table_name} ON #{Note.table_name}.source_type='Deal' AND #{Deal.table_name}.id = #{Note.table_name}.source_id " +
                                      "LEFT JOIN #{Project.table_name} ON #{Deal.table_name}.project_id = #{Project.table_name}.id"}
   
  def project   
    source.project
  end
             
  def editable_by?(usr)   
    true
    # usr && usr.logged? && (usr.allowed_to?(:edit_notes, project) || (self.author == usr && usr.allowed_to?(:edit_own_notes, project)))
  end

  def destroyable_by?(usr)                                      
    usr && (usr.allowed_to?(:edit_contacts, project) || (self.author == usr && usr.allowed_to?(:add_notes, project)))
  end
       
  
  private
  
  def send_mails   
    if self.source.class == Contact && !self.source.is_company
      parent = Contact.find_by_first_name(self.source.company)
    end
    Mailer.deliver_note_added(self, parent)
  end
  

end
                    

