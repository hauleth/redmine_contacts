class AddIsCompanyToCustomers < ActiveRecord::Migration
  def self.up
    add_column :customers, :is_company, :boolean, :default => false
  end

  def self.down
    remove_column :customers, :is_company
  end
end
