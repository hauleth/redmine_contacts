# Use rake db:migrate_plugins to migrate installed plugins
class RenameCustomerStatusField < ActiveRecord::Migration
  def self.up
    rename_column :customers, :customer_status_id, :status_id
   end

  def self.down
    rename_column :customers, :status_id, :customer_status_id
  end
end
