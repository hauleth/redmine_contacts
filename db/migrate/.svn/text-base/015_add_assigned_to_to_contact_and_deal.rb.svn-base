class AddAssignedToToContactAndDeal < ActiveRecord::Migration
  def self.up
    add_column :contacts, :assigned_to_id, :integer
    add_column :deals, :assigned_to_id, :integer
  end

  def self.down
    remove_column :contacts, :assigned_to_id
    remove_column :deals, :assigned_to_id
    
  end
  
end
