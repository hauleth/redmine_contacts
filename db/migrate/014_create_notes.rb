class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.column :subject, :string
      t.column :content, :text
      t.references :source, :polymorphic => true
      t.references :author

      t.timestamps
    end
    
    rename_column :contacts, :notes, :background
  end

  def self.down
    drop_table :notes 
    rename_column :contacts, :background, :notes
  end
end
