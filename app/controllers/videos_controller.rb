class VideosController < ApplicationController
  respond_to :html

  def index
    authorize! :read, Video
    @videos = Video.all
  end

  def show
    @video = Video.find params[:id]
    authorize! :read, @video
  end

  def download
    @video = Video.find params[:id]
    authorize! :read, @video

    if can?(:read, @video)
      send_file @video.video.current_path, :x_sendfile => true, :disposition => 'attachment'
      current_user.update_column(:byte_download, current_user.byte_download + @video.size)
    else
      redirect_to assets_path('access_denied.jpg'), :status => 403
    end
  end

  def download_contact_sheet
    @video = Video.find params[:id]
    authorize! :read, @video.board_thread

    if true or can?(:read, @video) # We short cut the test, anyone can see the contact sheet
      if @video.contact_sheet_path and File.exist?(@video.contact_sheet_path)
        send_file @video.contact_sheet_path, :x_sendfile => true, :disposition => 'inline'
      else
        redirect_to assets_path('no-preview.jpg')
      end
    else
      redirect_to assets_path('access_denied.jpg'), :status => 403
    end
  end

  def new
    name_space = NameSpace.find params[:id]
    authorize! :create_video, name_space

    @board_thread = BoardThread.new
    @board_thread.name_space = name_space
    @board_thread.build_video
    @board_thread.posts.build

    add_to_crumbs(@board_thread.video)
  end

  def create
    @board_thread = BoardThread.new(params.require(:board_thread).permit(:title, :name_space_id, :posts_attributes => [:text], :video_attributes => [:video]))
    authorize! :create_video, @board_thread.name_space

    @board_thread.posts.first.user = current_user
    @board_thread.user = current_user
    @board_thread.video.user = current_user
    @board_thread.index = @board_thread.name_space.index
    @board_thread.picture_freeze = true

    if @board_thread.save
      redirect_to @board_thread, :notice => 'Video thread was successfully created.'
    else
      render :action => 'new'
    end
  end

  private
end
