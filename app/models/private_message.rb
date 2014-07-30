class PrivateMessage < ActiveRecord::Base
  self.per_page = 20

  validates :sender_id, :presence => true
  validates :receiver_id, :presence => true
  validates :subject, :presence => true
  validates :text, :presence => true

  validate :can_receive?

  belongs_to :sender, :class_name => 'User'
  belongs_to :receiver, :class_name => 'User'

  belongs_to :parent, :class_name => 'PrivateMessage', :foreign_key => 'reply_id'
  has_many :replies, :class_name => 'PrivateMessage', :foreign_key => 'reply_id'

  def can_see?(user)
    user == self.sender or user == self.receiver
  end

  def can_receive?
    true
  end

  def mark_read user
    if user == receiver
      update(read: true)
    end
  end
end
