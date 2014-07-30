class PostsController < ApplicationController
  respond_to :html

  def show
    @post = Post.find(params[:id])
    authorize! :read, @post

    @needs_sprites = sprites_board_thread_path(@post.board_thread) if @post.images.any?

    add_to_crumbs(@post)
  end

  def download
    @post = Post.find(params[:id])
    authorize! :download, @post

    if File.exist? @post.zip_file_name
      send_file @post.zip_file_name, :x_sendfile => true, :type => 'application/zip', :disposition => 'attachment', :filename => "post-#{@post.id}-in-#{@post.board_thread.title}.zip"
      headers['Content-Length'] = File.size(@post.zip_file_name).to_s
      current_user.update_column(:byte_download, current_user.byte_download + File.size(@post.zip_file_name))
    else
      @post.create_zip
      redirect_to view_context.link_to_post_in_thread(@post), :notice => 'No Zip is ready, try again later (creation queued)'
    end
  end

  def new
    @board_thread = BoardThread.find(params[:board_thread_id])
    @post = Post.new
    @post.board_thread =
    authorize! :create_post, @board_thread

    add_to_crumbs @post

    @post.board_thread_id = params[:board_thread_id]
    @post.parent_id = params[:id] if params[:id]
  end

  def create
    @post = Post.new(params.require(:post).permit(:text, :board_thread_id, :parent_id, :images_attributes => [:image]))
    authorize! :create_post, @post.board_thread

    @post.user = current_user

    if params[:images] and can?(:attach_pictures, @post.board_thread)
      params[:images].each do |im|
        @post.images.build(:image => im, :user_id => current_user.id, :board_thread_id => @post.board_thread_id)
      end
    end

    if @post.save
      @post.board_thread.touch

      flash[:notice] = "Post was successfully created. with #{@post.images.count} images."
      redirect_to view_context.link_to_post_in_thread(@post)
    else
      flash[:error] = "Post failed #{@post.errors.full_messages.each { |e| e }}"
      redirect_to new_board_thread_post_path(@post.board_thread, @post)
    end
  end

  def edit
    @post = Post.find(params[:id])
    authorize! :update, @post
    add_to_crumbs @post
  end

  def move
    @post = Post.find(params[:id])
    authorize! :update, @post

    if @post.move_to(params[:post][:board_thread_id])
      redirect_to view_context.link_to_post_in_thread(@post), :notice => 'Post was successfully moved.'
    else
      redirect_to view_context.link_to_post_in_thread(@post), :notice => 'Move failed. Thread does not exist.'
    end

  end

  def update
    @post = Post.find(params[:id])
    authorize! :update, @post

    if @post.update_attributes(params.require(:post).permit(:text))
      redirect_to view_context.link_to_post_in_thread(@post), :notice => 'Post was successfully updated.'
    else
      add_to_crumbs @post
      render :edit
    end
  end

  def destroy
    post = Post.find(params[:id])
    authorize! :delete, post

    board_thread = post.board_thread
    post.child_posts.each { |child| child.parent_id = post.parent_id; child.save }
    post.destroy

    redirect_to board_thread
  end

  def report
    @post = Post.find(params[:id])

    @report = Report.new
    @report.post = @post

    authorize! :create, @report
    add_to_crumbs @report
  end
end
