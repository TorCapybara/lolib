class Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :board_thread
  belongs_to :rating_type
end
