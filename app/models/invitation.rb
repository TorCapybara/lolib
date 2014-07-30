class Invitation < ActiveRecord::Base
  belongs_to :mentor, :class_name => 'User', :foreign_key => 'mentor_id'
  belongs_to :user
end