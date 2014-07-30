class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :post, :counter_cache => true

  scope :filter_by_post, ->(post_id = nil) { where(post_id: post_id) }
  scope :filter_by_user, ->(user_id = nil) { where(user_id: user_id) }
end
