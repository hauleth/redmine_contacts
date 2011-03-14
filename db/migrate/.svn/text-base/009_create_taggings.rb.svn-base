class CreateTaggings < ActiveRecord::Migration
  def self.up      
    unless ActsAsTaggableOn::Tagging.table_exists?  
      create_table :taggings, :id => false do |t|
        t.column :tag_id, :integer
        t.column :container_id, :integer
        t.column :container_type, :string
      end
    end
  end


  def self.down
    drop_table :taggings
  end
end
