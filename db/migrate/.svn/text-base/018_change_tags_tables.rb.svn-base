class ChangeTagsTables < ActiveRecord::Migration
  def self.up   
    unless ActsAsTaggableOn::Tagging.column_names.include?("tagger_type") && ActsAsTaggableOn::Tagging.column_names.include?("context")    
      rename_column :taggings, :container_id, :taggable_id 
      rename_column :taggings, :container_type, :taggable_type    
    
      add_column :taggings, :id, :integer 
      add_column :taggings, :tagger_id, :integer
      add_column :taggings, :tagger_type, :string
      add_column :taggings, :context, :string, :default => "tags"
      add_column :taggings, :created_at, :datetime
      
      add_index :taggings, :tag_id, :name => "taggings_id"
      add_index :taggings, [:taggable_id, :taggable_type, :context], :name => "taggings_key"    
    end
  end

  def self.down 
    rename_column :taggings, :taggable_id, :container_id 
    rename_column :taggings, :taggable_type, :container_type           
    
    remove_column :taggings, :id
    remove_column :taggings, :tagger_id
    remove_column :taggings, :tagger_type
    remove_column :taggings, :context
    remove_column :taggings, :created_at
    
    
  end
  
end