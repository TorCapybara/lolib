class WikisController < ApplicationController
  respond_to :html
  helper_method :sort_column, :sort_direction

  def index
    authorize! :index, Wiki
    @wikis = Wiki.accessible_by(current_ability).order(sort_column + ' ' + sort_direction).paginate(:page => params[:page])
    add_to_crumbs(['Wiki', wikis_path])
  end

  def show
    @wiki = Wiki.find_by_name(params[:id])
    authorize! :read, @wiki
    add_to_crumbs(@wiki)

    @revision = params[:rev] ? @wiki.revisions.find_by_revision(params[:rev]) : @wiki.last_revision
    @html_content = RedCloth.new(@revision.content).to_html
  end

  def new
    @wiki = Wiki.new
    @wiki.revisions.build
    authorize! :create, @wiki
    add_to_crumbs(@wiki)
  end

  def create
    @wiki = Wiki.new(params.require(:wiki).permit(:name, :revisions_attributes => [:content]))
    authorize! :create, @wiki

    @wiki.revisions.first.revision = 1
    @wiki.revisions.first.user = current_user

    if @wiki.save
      redirect_to @wiki, :notice => 'Wiki was successfully created.'
    else
      render :new
    end
  end

  def edit
    @wiki = Wiki.find_by_name(params[:id])
    authorize! :update, @wiki
    add_to_crumbs(@wiki)
  end

  def update
    @wiki = Wiki.find_by_name(params[:id])
    authorize! :update, @wiki

    r = @wiki.revisions.build
    r.revision = @wiki.last_revision.revision + 1
    r.content = params[:wiki][:revisions_attributes].first.last[:content]
    r.user = current_user

    if r.save
      redirect_to @wiki, :notice => 'Wiki was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @wiki = Wiki.find(params[:id])
    authorize! :delete, @wiki
    @wiki.destroy

    redirect_to wikis_path
  end

private
  def sort_column
    Wiki.column_names.include?(params[:sort]) ? params[:sort] : 'name'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
