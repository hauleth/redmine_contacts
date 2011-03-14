# Use rake db:migrate_plugins to migrate installed plugins
class AddAvatarToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :avatar, :string
  end

  def self.down
    remove_column :customers, :avatar
  end
end
