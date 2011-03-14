# Use rake db:migrate_plugins to migrate installed plugins
class AddCustomerFields < ActiveRecord::Migration
  def self.up
    add_column :customers, :birthday, :date
    rename_column :customers, :name, :first_name
    add_column :customers, :last_name, :string
    add_column :customers, :middle_name, :string
    add_column :customers, :customer_status_id, :integer
  end

  def self.down
    remove_column :customers, :customer_status_id
    remove_column :customers, :middle_name
    remove_column :customers, :last_name
    rename_column :customers, :first_name, :name
    remove_column :customers, :birthday
  end
end
