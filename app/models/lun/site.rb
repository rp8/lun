class Lun::Site < ActiveRecord::Base
  set_table_name 'lun_sites'
  has_many :topics, :class_name => 'Lun::Topic'
  has_many :links, :class_name => 'Lun::Link'

  def self.json_except
    [:id]
  end


end
