class AddJobTitleToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :job_title, :string
    drop_table :customer_statuses
    remove_column :customers, :status_id
  end

  def self.down
    remove_column :customers, :job_title   
    create_table :customer_statuses do |t|
      t.column :name, :string
      t.column :position, :integer
    end
    add_column :customers, :status_id, :integer                
    
  end
end
