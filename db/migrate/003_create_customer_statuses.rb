class CreateCustomerStatuses < ActiveRecord::Migration
  def self.up
    create_table :customer_statuses do |t|
      t.column :name, :string
      t.column :position, :integer
    end
  
  end

  def self.down
    drop_table :customer_statuses
  end
end
