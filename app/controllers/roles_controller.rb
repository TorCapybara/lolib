class RolesController < ApplicationController
  respond_to :html

  def index
    authorize! :index, @role
    @roles = Role.all
    add_to_crumbs ['Roles', roles_path]

  end

  def show
    @role = Role.find_by_id params[:id]
    authorize! :read, @role
    add_to_crumbs(@role)
  end
end
