class WarningsController < ApplicationController
  respond_to :html

  def new
    authorize! :create, Warning
    @user = User.find params[:user_id]
    @warning = Warning.new
    add_to_crumbs(@user)
  end

  def create
    authorize! :create, Warning
    @warning = Warning.new(params.require(:warning).permit(:reason))
    @user = User.find(params[:user_id])

    @warning.moderator = current_user
    @warning.user = @user

    if @warning.save
      flash[:notice] = 'Warning issued'
      redirect_to @warning
    else
      render :new
    end
  end

  def edit
    @warning = Warning.find params[:id]
    authorize! :update, @warning
    add_to_crumbs(@warning)
  end

  def update
    @warning = Warning.find params[:id]
    authorize! :update, Warning

    @warning.update(params.require(:warning).permit(:reason))
    if @warning.save
      flash[:notice] = 'Warning updated'
      redirect_to warning_path(@warning)
    else
      render :edit
    end
  end

  def show
    @warning = Warning.find(params[:id])
    authorize! :read, @warning
    add_to_crumbs(@warning)
  end
end
