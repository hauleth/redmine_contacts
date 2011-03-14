class AddStatusToDeal < ActiveRecord::Migration
  def self.up
    add_column :deals, :status_id, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :deals, :status_id
  end
  
end