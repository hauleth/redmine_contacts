class Contact < ActiveRecord::Base
  unloadable  
  has_many :notes, :as => :source, :dependent => :delete_all, :order => "created_on DESC"
  belongs_to :assigned_to, :class_name => 'User', :foreign_key => 'assigned_to_id'    
  has_and_belongs_to_many :issues, :order => "#{Issue.table_name}.due_date", :uniq => true   
  has_and_belongs_to_many :deals, :order => "#{Deal.table_name}.status_id"  
  has_and_belongs_to_many :projects, :uniq => true   
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  
  attr_accessor :phones     
  attr_accessor :emails 
  
  acts_as_taggable
  
  acts_as_watchable

  acts_as_attachable :view_permission => :view_contacts,  
                     :delete_permission => :edit_contacts

  # acts_as_activity_provider :type => 'contacts',
  #                           :timestamp => "#{Contact.table_name}.created_on",
  #                           :author_key => "#{Contact.table_name}.author_id",
  #                           :permission => :view_contacts

  acts_as_event :datetime => :created_on,
                :url => Proc.new {|o| {:controller => 'contacts', :action => 'show', :id => o}}, 	
                :type => Proc.new {|o| 'contact' },  
                :title => Proc.new {|o| o.name },
                :description => Proc.new {|o| o.notes }     
                
  named_scope :visible, lambda {|*args| { :include => :projects,
                                          :conditions => Project.allowed_to_condition(args.first || User.current, :view_contacts) } }                
  named_scope :in_project, lambda {|*args| { :include => :projects, :conditions => ["#{Project.table_name}.id = ?", args.first]}}
  
  named_scope :order_by_name, :order => "#{Contact.table_name}.last_name, #{Contact.table_name}.first_name"               
                
  # name or company is mandatory
  validates_presence_of :first_name 
  validates_uniqueness_of :first_name, :scope => [:last_name, :middle_name, :company]
  
  def public?
    true
  end        
  
  def private?
    false
  end
  
  def visible?(usr=nil)
    (usr || User.current).allowed_to?(:view_contacts, self.project)
  end
   
  def project
    self.projects.first
  end
  
  def name
    result = []
    if !self.is_company
      [self.last_name, self.first_name, self.middle_name].each {|field| result << field unless field.blank?}
    else
      result << self.first_name
    end    

    return result.join(" ")
  end
     
  def phones                            
    @phones || self.phone ? self.phone.split( /, */) : []
  end   
  
  def emails                            
    @emails || self.email ? self.email.split( /, */) : []
  end
  
  
  private
  
  def assign_phone      
    if @phones
      self.phone = @phones.uniq.map {|s| s.strip.delete(',').squeeze(" ")}.join(', ')
    end
  end 
  
end
