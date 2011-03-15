class CreateContactsProjects < ActiveRecord::Migration         
  def self.up  
    create_table :contacts_projects, :id => false do |t|
      t.column :project_id, :integer, :default => 0, :null => false
      t.column :contact_id, :integer, :default => 0, :null => false
    end              

    Contact.find(:all).each do |contact|
      contact.projects << Project.find(contact.project_id)
    end
  end

  def self.down
    drop_table :contacts_projects 
  end                                                
end         
