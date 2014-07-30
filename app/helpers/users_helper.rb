module UsersHelper
  def link_user user
    link_to_if(can?(:read, user), user ? user.name : "Anonymous User", user)
  end
end
