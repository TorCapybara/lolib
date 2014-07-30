class Role < ActiveRecord::Base
  has_many :users
  has_many :board_accesses

  def restricted_user?
    name == 'restricted_user' or name == 'banned' or name == 'anonymous'
  end

end
