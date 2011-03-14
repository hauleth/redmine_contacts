class Tagging < ActiveRecord::Base
  unloadable
  belongs_to :contractor, :class_name => "Contact", :foreign_key => "contractor_id"
  belongs_to :deal
  
end
