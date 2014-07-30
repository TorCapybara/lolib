class BoardAccess < ActiveRecord::Base
  include FlagShihTzu

  has_flags 1 => :read,       # Board Visible / Can see Threads / Posts
            2 => :write,      # Can create new threads
            3 => :answer,     # Can answer in old threads
            4 => :pictures,   # Can answer with pictures
            5 => :download,   # Can download Images / Zips
            6 => :video,      # Can create video threads / download videos (needs download too)
            7 => :manage      # Can manage Image, Posts and Threads and edit current Namespace


  belongs_to :name_space
  belongs_to :role

  scope :filter_by_role, ->(role_id = nil) { where(role_id: role_id) }

end
