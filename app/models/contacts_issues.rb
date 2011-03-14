class ContactsIssues < ActiveRecord::Base              
  validates_presence_of :contact_id, :issue_id
  validates_uniqueness_of :contact_id, :scope => [:issue_id]                   
 
  after_create :send_mails     
  after_save :send_mails
  
private

  def send_mails    
    Mailer.deliver_issue_connected(Contact.find(self.contact_id), Issue.find(self.issue_id)) 
    return true
  end
   
end
