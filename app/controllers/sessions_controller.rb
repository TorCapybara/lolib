class SessionsController < ApplicationController
  respond_to :html

  def new
    authorize! :login, nil
    add_to_crumbs(['Log in', login_path])
  end

  def create
    authorize! :login, nil
    user = User.find_by_name(params[:name])

    if user && user.authenticate(params[:password])
      flash[:notice] = I18n.t :'session.logged_in'
      session[:user_id] = user.id
      redirect_to(root_path + '#login-modal')
    else
      add_to_crumbs(['Log in', login_path])
      flash[:error] = I18n.t :'session.invalid_user_password'
      render :new
    end
  end

  def destroy
    authorize! :logout, nil

    session[:user_id] = nil
    flash[:notice] = I18n.t I18n.t :'session.logged_out'
    redirect_to root_path
  end
end
