class Tagging < ActiveRecord::Base
  unloadable 
    
  set_table_name "contacts_taggings" 
  
  belongs_to :container, :polymorphic => true
  belongs_to :tag
  
end
