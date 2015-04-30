class Lun::User < User
  has_many :comments, :class_name => 'Lun::Comment'

  def self.json_except
    [:email, :password, :openid, :login]
  end

end
