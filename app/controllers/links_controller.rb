class LinksController < ApplicationController
  respond_to :html
  helper_method :sort_column, :sort_direction

  def index
    authorize! :index, Link
    @links = Link.accessible_by(current_ability).order(sort_column + ' ' +sort_direction)
    @ping_backs = PingBack.all.order('updated_at DESC')

    add_to_crumbs(['Links', links_path])
  end

  def redirect
    @link = Link.find(params[:id])
    authorize! :read, @link

    Link.increment_counter(:views, @link.id)

    redirect_to @link.uri
  end

  def edit
    @link = Link.find(params[:id])
    authorize! :update, @link

    add_to_crumbs(['Links', links_path])
  end

  def update
    @link = Link.find(params[:id])
    authorize! :update, @link

    if @link.update_attributes(link_params)
      redirect_to links_path, notice: 'Link was successfully updated.'
    else
      render 'edit'
    end
  end

  def new
    authorize! :create, Link
    @link = Link.new

    add_to_crumbs(['Links', links_path])
  end

  def create
    @link = Link.new(link_params)
    authorize! :create, @link

    if @link.save
      redirect_to links_path, notice: 'Link was successfully created.'
    else
      render 'new'
    end
  end


  def delete
    @link = Link.find(params[:id])
    authorize! :delete, @link

    add_to_crumbs(['Links', links_path])
  end

  def destroy
    @link = Link.find(params[:id])
    authorize! :delete, @link

    @link.destroy

    redirect_to links_path
  end

private
  def link_params
    params.require(:link).permit(:uri, :name, :description)
  end

  def sort_column
    Link.column_names.include?(params[:sort]) ? params[:sort] : 'uptime'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
  end
end
