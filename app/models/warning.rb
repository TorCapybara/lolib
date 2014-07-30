class Warning < ActiveRecord::Base
  belongs_to :user
  belongs_to :moderator, :class_name => 'User', :foreign_key => :moderator_id

  scope :active_warnings, -> { where('created_at > ?', Time.now - 14.days) }

end
