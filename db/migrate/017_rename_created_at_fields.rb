class RenameCreatedAtFields < ActiveRecord::Migration
  def self.up
    rename_column :deals, :created_at, :created_on 
    rename_column :notes, :created_at, :created_on 
    rename_column :deals, :updated_at, :updated_on 
    rename_column :notes, :updated_at, :updated_on 
  end

  def self.down
    rename_column :deals, :created_on, :created_at 
    rename_column :notes, :created_on, :created_at 
    rename_column :deals, :updated_on, :updated_at 
    rename_column :notes, :updated_on, :updated_at 
  end
  
end