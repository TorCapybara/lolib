class Ability
  include CanCan::Ability

  def initialize(user)
    # Standard: :index, :create, :read, :update, :delete
    # We use: :create_board, NameSpace, :create_video, NameSpace and :create_post, BoardThread
    # The reason is: these creates should not be global but given via BoardAccess
    # Additionally used generic: :login, :logout, :search
    # Additionally used on model:
    # * :attach_pictures, BoardThread
    # * :download, (BoardThread, Post, Image)
    # * :change_password, @user
    # * :change_settings, @user
    # * :detail, User

    rules_from_board_access(user)

    case user.role.name
      when 'admin'
        can :manage, :all
      when 'moderator'
        can :read, Role
        can :read, User
        can :detail, User
        can [:change_password, :change_settings], User, id: user.id
        can :update, User, id: user.id
        can :read, PrivateMessage, :sender_id => user.id
        can :read, PrivateMessage, :receiver_id => user.id
        can :create, PrivateMessage, :sender_id => user.id
        can :create, Invitation
        can :create, NameSpace
        can :manage, Wiki
        can :manage, Warning
        can :manage, Report
        can :search
        can :logout
      when 'user', 'master'
        rules_from_board_access(user)

        can :create, Invitation if user.invitations.none? or (user.invitations.last.created_at < DateTime.now - 7.days)
        can [:change_password, :change_settings], User, id: user.id
        can :update, User, id: user.id
        can :read, Warning, user_id: user.id
        can :read, PrivateMessage, :sender_id => user.id
        can :read, PrivateMessage, :receiver_id => user.id
        can :create, PrivateMessage, :sender_id => user.id

        can :search
        can :read, User
        can :logout
      when 'restricted_user'
        can [:change_password, :change_settings], User, id: user.id
        can :read, PrivateMessage, :sender_id => user.id
        can :read, PrivateMessage, :receiver_id => user.id
        can :create, PrivateMessage do |private_message|
          (private_message.receiver.role.name == 'admin') or (private_message.parent.receiver == user)
        end

        can :search
        can :read, User, :id => user.id
        can :logout
      when 'anonymous'
        can :create, User
        can :login
      when 'banned'
        can :logout
    end

    # For everyone

    # Wiki
    can :read, Wiki

    # Link
    can :read, Link

    # Like
    can :manage, Like

    # Report
    can :create, Report
  end

  def rules_from_board_access(user)
    # NameSpace
    can :read, NameSpace do |name_space|
      name_space.board_accesses.filter_by_role(user.role_id).first.read
    end
    can :update, NameSpace do |name_space|
      name_space.board_accesses.filter_by_role(user.role_id).first.manage
    end

    # BoardThread
    can :read, BoardThread do |board_thread|
      board_thread.name_space.board_accesses.filter_by_role(user.role_id).first.read
    end
    can :download, BoardThread do |board_thread|
      board_thread.name_space.board_accesses.filter_by_role(user.role_id).first.download or board_thread.free_download
    end
    can :create_board_thread, NameSpace do |name_space|
      name_space.board_accesses.filter_by_role(user.role_id).first.write
    end
    can [:update, :delete], BoardThread do |board_thread|
      board_thread.name_space.board_accesses.filter_by_role(user.role_id).first.manage
    end
    can :attach_pictures, BoardThread do |board_thread|
      board_thread.name_space.board_accesses.filter_by_role(user.role_id).first.pictures and !board_thread.picture_freeze
    end


    # Post
    can :read, Post do |post|
      post.board_thread.name_space.board_accesses.filter_by_role(user.role_id).first.read
    end
    can :download, Post do |post|
      post.board_thread.name_space.board_accesses.filter_by_role(user.role_id).first.download or (post.user_id == user.id) or post.board_thread.free_download
    end
    can :create_post, BoardThread do |board_thread|
      board_thread.name_space.board_accesses.filter_by_role(user.role_id).first.answer and !board_thread.closed
    end
    can :update, Post do |post|
      post.board_thread.name_space.board_accesses.filter_by_role(user.role_id).first.manage or (post.user_id == user.id)
    end
    can :delete, Post do |post|
      post.board_thread.name_space.board_accesses.filter_by_role(user.role_id).first.manage
    end

    # Image
    can :read, Image do |image|
      image.board_thread.name_space.board_accesses.filter_by_role(user.role_id).first.read
    end
    can :download, Image do |image|
      image.board_thread.name_space.board_accesses.filter_by_role(user.role_id).first.download or (image.user_id == user.id) or image.board_thread.free_download
    end
    can :delete, Image do |image|
      image.board_thread.name_space.board_accesses.filter_by_role(user.role_id).first.manage
    end

    # Video / Video Threads
    can :create_video, NameSpace do |name_space|
      name_space.board_accesses.filter_by_role(user.role_id).first.video
    end
    can :read, Video do |video|
      bc = video.board_thread.name_space.board_accesses.filter_by_role(user.role_id).first
      (bc.video and bc.download) or video.board_thread.free_download
    end

  end
end
