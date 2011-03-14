# Use rake db:migrate_plugins to migrate installed plugins
class AddFieldsToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :created_on, :datetime
    add_column :customers, :updated_on, :datetime
    add_column :customers, :comments_count, :integer, :default => 0,  :null => false
  end

  def self.down
    remove_column :customers, :created_on
    remove_column :customers, :updated_on
    remove_column :customers, :comments_count
  end
end
