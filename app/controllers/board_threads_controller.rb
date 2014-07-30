class BoardThreadsController < ApplicationController
  respond_to :html
  helper_method :sort_column, :sort_direction

  def index
    @page = params[:page] || 1
    authorize! :index, BoardThread
    @board_threads = BoardThread.order(sort_column + ' ' + sort_direction).includes(:name_space, :posts).paginate(:page => @page)

    add_to_crumbs(['Thread Index', board_threads_path])
  end

  def index_images
    @page = params[:page] || BoardThread.where('images_count > 0').index.paginate(:page => params[:page]).total_pages
    authorize! :index, BoardThread
    @board_threads = BoardThread.where('images_count > 0').index.paginate(:page => @page)

    add_to_crumbs(['Image Index', preview_board_threads_path])
  end

  def show
    setup_show
    @needs_sprites = sprites_board_thread_path(@board_thread) if @board_thread.images.any?
  end

  def show_images
    setup_show
    @needs_sprites = sprites_board_thread_path(@board_thread) if @board_thread.images.any?
  end

  def show_links
    setup_show
  end

  def download
    @board_thread = BoardThread.find(params[:id])
    authorize! :download, @board_thread

    if File.exist? @board_thread.zip_file_name
      send_file @board_thread.zip_file_name, :x_sendfile => true, :type => 'application/zip', :disposition => 'attachment', :filename => "#{@board_thread.id}-#{@board_thread.title}.zip"
      headers['Content-Length'] = File.size(@board_thread.zip_file_name).to_s
      current_user.update_column(:byte_download, current_user.byte_download + File.size(@board_thread.zip_file_name))

    else
      @board_thread.create_zip
      redirect_to links_board_thread_path(@board_thread), :notice => 'No Zip is ready, try again later (creation queued)'
    end
  end

  def download_verification
    @board_thread = BoardThread.find(params[:id])
    authorize! :read, @board_thread

    send_data @board_thread.verification_file(params[:format]), :filename => @board_thread.title + '.' + params[:format], :disposition => 'attachment'
  end

  def new
    name_space = NameSpace.find params[:id]
    @board_thread = BoardThread.new
    @board_thread.name_space = name_space
    authorize! :create_board_thread, name_space


    @board_thread.posts.build
    @board_thread.posts.first.images.build

    add_to_crumbs(@board_thread)
  end

  def create
    @board_thread = BoardThread.new(params.require(:board_thread).permit(:title, :name_space_id, :posts_attributes => [:text, :images_attributes => [:image]]))
    authorize! :create_board_thread, @board_thread.name_space

    @board_thread.user = current_user
    @board_thread.posts.first.user = current_user
    @board_thread.index = @board_thread.name_space.index

    if params[:images]
      params[:images].each do |im|
        i = @board_thread.posts.first.images.build(:image => im, :user_id => current_user.id, )
        @board_thread.images << i
      end
    end

    if @board_thread.save
      BoardThread.reset_counters(@board_thread.id, :images) # Hack (avoid duplicate count of images)

      redirect_to @board_thread, :notice => 'Board thread was successfully created.'
    else
      render :action => 'new'
    end
  end

  def edit
    @board_thread = BoardThread.find(params[:id])
    authorize! :update, @board_thread

    add_to_crumbs(@board_thread)
  end

  def update
    @board_thread = BoardThread.find(params[:id])
    authorize! :update, @board_thread

    if @board_thread.update_attributes(params.require(:board_thread).permit(:title, :name_space_id, :sticky, :picture_freeze, :closed, :announced, :index, :free_download))
      redirect_to @board_thread, :notice => 'Board thread was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @board_thread = BoardThread.find(params[:id])
    authorize! :delete, @board_thread

    @board_thread.posts.each do |post|
      post.images.each do |image|
        image.destroy
      end
      post.destroy
    end
    @board_thread.destroy

    redirect_to board_threads_path
  end

  def sprites
    @board_thread = BoardThread.find(params[:id])
    authorize! :read, @board_thread

    fresh_when(@board_thread)

    send_file @board_thread.sprites, :x_sendfile => true, :disposition => 'inline', :filename => "sprites_#{@board_thread.id}.jpg"
  end

  private
  def sort_column
    BoardThread.column_names.include?(params[:sort]) ? params[:sort] : 'updated_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
  end

  def setup_show
    @board_thread = BoardThread.includes(:posts, :images).find(params[:id])
    authorize! :read, @board_thread

    add_to_crumbs @board_thread
    thread_seen
  end

  def thread_seen
    BoardThread.increment_counter(:views, @board_thread.id)
  end
end
