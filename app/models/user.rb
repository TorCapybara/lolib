class User < ActiveRecord::Base
  self.per_page = 25

  has_secure_password
  validates_presence_of :password, :if => :password
  validates :password, :length => {:minimum => 6}, :if => :password

  validates :name, :uniqueness => {:case_sensitive => false}
  validates :name, :exclusion => {:in => %w(Guest guest Boy boy Girl girl), :message => 'Name %{value} is reserved.'}
  validates :name, :length => {:minimum => 3}, :format => {:with => /\A[\p{Word}\w\s-]*\z/}, :on => :create
  validate :garbled, :on => :create

  validates :read_rules, :acceptance => true

  belongs_to :role
  belongs_to :mentor, :class_name => 'User', :foreign_key => 'mentor_id'

  has_many :board_threads
  has_many :ratings
  has_many :post_likes, :class_name => 'Like', :foreign_key => 'user_id'
  has_many :posts
  has_many :images
  has_many :videos
  has_many :invitations, :foreign_key => 'mentor_id'
  has_many :inbox_messages, :class_name => 'PrivateMessage', :foreign_key => 'receiver_id'
  has_many :outbox_messages, :class_name => 'PrivateMessage', :foreign_key => 'sender_id'
  has_many :referers
  has_many :warnings
  has_many :reports

  mount_uploader :avatar, AvatarUploader

  scope :users_online, -> { where('last_online > ?', Time.now - 20.minute) }

  def pm_targets
    if role.restricted_user?
      User.where('users.role_id = ?', Role.find_by_name('admin'));
    else
      User.where('users.role_id != ? AND users.role_id != ?', Role.find_by_name('restricted_user'), Role.find_by_name('banned')).where('users.name != \'anonymous\'').order('name desc')
    end
  end

  def unread_messages
    inbox_messages.where(:read => false).count
  end

  def css_options
    {0 => 'full', 1 => 'moderate', 2 => 'simple'}
  end

  def css_level
    return css_options[css]
  end

  private
  def garbled
    if name =~ /asdf|fdsa|ewq|qwer|yxcv|zx|xz|xx|xyz|qq|yy|zzz|abc/i
      errors.add(:name, 'is garbled')
    end
    if name =~ /anon|guest/i
      errors.add(:name, 'is garbled (anon/guest rule')
    end
    if name =~ /Capy|admin|top/i
      errors.add(:name, 'is garbled (admin rule)')
    end
    if name =~ /dick|shit|fuck|ass|piss|penis|vagina|faggot|hitler|asshole/i
      errors.add(:name, 'is garbled (language rule)')
    end
    if name =~ /[0-9]/i
      errors.add(:name, 'is garbled (remove your numbers)')
    end
    if name == name.upcase
      errors.add(:name, 'is garbled (Do not shout)')
    end
  end
end
