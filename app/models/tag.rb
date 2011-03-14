class Tag < ActiveRecord::Base
  unloadable     
  
  set_table_name "contacts_tags"
  
  has_many :taggings
  has_many :contacts, :through => :taggings, :source => :container, :source_type => 'Contact'
  
  validates_presence_of :name
  validates_uniqueness_of :name

  before_save :assign_color
  attr_reader :color_name

  def color_name
    return "##{ self.color.to_s(16) unless self.color.nil?}"
  end
 
  private
    
  def assign_color
    self.color = rand(0xffffff)
  end

end
