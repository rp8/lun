class Lun::Topic < ActiveRecord::Base
  set_table_name 'lun_topics'
  belongs_to :site, :class_name => 'Lun::Site'
  has_many :comments, :class_name => 'Lun::Comment'
  
  before_save :check_blanks

  attr_accessor :new_site

  def new_site?
    defined?(@new_site) && @new_site
  end

  def self.json_except
    [:id, :site_id]
  end

  private

  def check_blanks
    self.title = self.url unless self.title
  end
end
