class UsersController < ApplicationController
  respond_to :html
  helper_method :sort_column, :sort_direction

  def index
    authorize! :read, User
    @users = User.accessible_by(current_ability).order(sort_column + ' ' + sort_direction).paginate(:page => params[:page])

    add_to_crumbs ['User', users_path]
  end

  def show
    setup_show
  end

  def show_posts
    setup_show

    @page = params[:page] || 1
    @board_threads = BoardThread.joins(:posts).where('posts.user_id = ?', @user.id).uniq.order('board_threads.updated_at desc').paginate(:page => @page)
  end

  def show_referers
    setup_show

    @referers = @user.referers.paginate(:page => @page)
  end

  def new
    @user = User.new
    authorize! :create, @user

    add_to_crumbs(['Sign up', signup_path])
  end

  def create
    @user = User.new(params.require(:user).permit(:name, :password, :password_confirmation, :read_rules))
    authorize! :create, @user

    invitation = Invitation.find_by_invitation_code(params[:code])
    if params[:no_garbage] != '1'
      flash.now[:error] = 'Garbled nicks are not allowed - create a useful nick.'
    else
      if invitation and invitation.user == nil
        @user.role = Role.find_by_name('user')
        @user.mentor = invitation.mentor
        if @user.save(:validate => false)
          invitation.user = @user
          invitation.save
          redirect_to new_session_path, :notice => 'Signed up!'
          return
        end
      elsif params[:no_code] == '1'
        @user.role = Role.find_by_name('restricted_user')
        if @user.save
          redirect_to new_session_path, :notice => 'Signed up!'
          return
        else
        end
      else
        flash.now[:error] = 'You provided no valid invitation code.'
      end
    end
    add_to_crumbs(['Sign up', signup_path])
    render :new
  end

  def edit
    if params[:id] == 'me'
      @user = current_user
    else
      @user = User.find(params[:id])
    end
    authorize! :update, @user

    add_to_crumbs(@user)
  end

  def update
    @user = User.find(params[:id])
    authorize! :update, @user

    if @user.update_attributes(params.require(:user).permit(:likes, :tor_chat, :description, :avatar, :remove_avatar))
      redirect_to @user, :notice => 'User was successfully updated.'
    else
      render :edit
    end
  end

  def change_password
    @user = User.find(params[:id])
    authorize! :change_password, @user

    if request.patch?
      if @user.authenticate(params[:old_password])
        if @user.update_attributes(params.require(:user).permit(:password, :password_confirmation))
          redirect_to @user, :notice => 'Password was successfully updated.'
        else
          flash[:error] = "Change failed #{@user.errors.full_messages.each { |e| e }}"
          render :change_password
        end
      else
        flash[:error] = 'Old password is wrong'
        render :change_password
      end
    end
    add_to_crumbs(@user)
  end

  def change_settings
    @user = User.find(params[:id])
    authorize! :change_settings, @user

    if request.patch?
      if @user.update_attributes(params.require(:user).permit(:css))
        flash[:notice] = 'User settings were successfully updated.'
      else
        flash[:error] = 'Failed to update User settings '
      end
    end
    add_to_crumbs(@user)
  end

  def delete
    @user = User.find(params[:id])
    authorize! :delete, @user
    add_to_crumbs(@user)
  end

  def destroy
    @user = User.find(params[:id])
    authorize! :delete, @user
    @user.destroy

    redirect_to users_path, :notice => 'User was successfully deleted.'
  end

  def create_invitation
    if params[:id] == 'me'
      @user = current_user
    else
      @user = User.find(params[:id])
    end

    add_to_crumbs(@user)
    authorize! :create, Invitation

    if request.post?
      generate_invitation(@user)
      redirect_to @user
    end
  end

  def trust
    @user = User.find(params[:id])
    add_to_crumbs(@user)
    authorize! :create, Invitation

    if request.post?
      if @user.role.restricted_user?
        if invitation = generate_invitation(current_user)
          @user.mentor = current_user
          @user.role = Role.find_by_name('user')
          @user.save
          invitation.user = @user
          invitation.save
        end
      else
        flash[:error] = 'This user is already a trusted member!'
      end
      redirect_to @user
    end
  end

  def generate_invitation user
    invitation = nil
    if can?(:create, Invitation)
      flash[:notice] = 'An invitation code has been created for you'
      invitation = Invitation.create(:invitation_code => get_invite_code)
      user.invitations << invitation
    else
      flash[:error] = 'Sorry, you can only create one invitation per week'
    end
    invitation
  end

  private
  def setup_show
    if params[:id] == 'me'
      @user = current_user
    else
      @user = User.find(params[:id])
    end

    authorize! :read, @user

    add_to_crumbs(@user)
  end

  def get_invite_code
    range = *('a'..'z')
    Array.new(10) { range.sample }.join
  end

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : 'name'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

end
