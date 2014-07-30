class NameSpacesController < ApplicationController
  respond_to :html
  helper_method :sort_column, :sort_direction

  def index
    authorize! :index, NameSpace
    @name_spaces = NameSpace.all # accessible_by(current_ability)
    @state = params[:state]

    add_to_crumbs ['Boards', name_spaces_path]
  end

  def show
    @name_space = NameSpace.find(params[:id])
    authorize! :read, @name_space
    add_to_crumbs(@name_space)

    @board_stickies = @name_space.board_threads.sticky
    @board_threads = @name_space.board_threads.not_sticky.order(sort_column + ' ' + sort_direction).paginate(:page => params[:page])
  end

  def show_images
    @name_space = NameSpace.find(params[:id])
    authorize! :read, @name_space
    add_to_crumbs(@name_space)

    @board_threads = @name_space.board_threads.paginate(:page => params[:page])
  end

  def download_verification
    @name_space = NameSpace.find(params[:id])
    authorize! :read, @name_space

    send_data @name_space.verification_file(params[:format]), :filename => @name_space.name + '.' + params[:format], :disposition => 'attachment'
  end

  def new
    @name_space = NameSpace.new
    authorize! :create, NameSpace

    Role.all.each do |role|
      board_access = @name_space.board_accesses.build
      board_access.role = role
    end

    add_to_crumbs nil

    @name_space.parent_id = params[:id]
  end

  def create
    @name_space = NameSpace.new(name_space_params)
    authorize! :create, NameSpace

    if @name_space.save
      redirect_to @name_space, :notice => 'Name space was successfully created.'
    else
      render :new
    end
  end

  def edit
    @name_space = NameSpace.find(params[:id])
    authorize! :update, @name_space
    add_to_crumbs(@name_space)

    @parent_spaces = NameSpace.all
  end


  def update
    @name_space = NameSpace.find(params[:id])
    authorize! :update, @name_space
    add_to_crumbs(@name_space)

    if @name_space.update_attributes(name_space_params)
      redirect_to @name_space, :notice => 'Name space was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @name_space = NameSpace.find(params[:id])
    @name_space.destroy

    redirect_to name_spaces_path
  end

  def sort_column
    BoardThread.column_names.include?(params[:sort]) ? params[:sort] : 'updated_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
  end

private
  def name_space_params
    params.require(:name_space).permit(:name, :parent_id, :sort_order, :index, :board_accesses_attributes => [:id, :read, :write, :answer, :pictures, :download, :video, :manage, :role_id])
  end
end
