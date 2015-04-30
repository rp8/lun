class Lun::Comment < ActiveRecord::Base
  set_table_name 'lun_comments'
  belongs_to :topic, :class_name => 'Lun::Topic'
  has_many :feedbacks, :class_name => 'Lun::Feedback'

  before_save :check_blanks

  validates_presence_of :created_by, :message => 'Name is required'
  validates_presence_of :email, :message => 'Email is required'
  validates_presence_of :content, :message => 'Comment is required'
  validates_format_of :email, :message => 'Invalid Email', 
    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
    :if => Proc.new {|c| c.email != nil and c.email != ''} 
  validates_format_of :website, :message => 'Invalid web address', 
    :if => Proc.new {|c| c.website != nil and c.website.strip != ''} , 
    :with => /http[s]?:\/\/.+/i

  def self.json_except
    [:topic_id, :user_id, :email, :ip, :disabled, :updated_by, :updated_on]
  end

  def save_as_reply!(parent)
    self.parent_id = parent.id
    self.level = parent.level + 1
    self.save!
  end

  private

  def check_blanks
    self.website = nil if !self.website.nil? and self.website.strip == ''
  end

end
