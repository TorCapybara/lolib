class LikesController  < ApplicationController
  respond_to :html

  def index
    authorize! :detail, current_user
    @likes = current_user.post_likes
  end

  def create
    authorize! :create, Like
    post = Post.find params[:id]

    if post.likes.where(user: current_user).any?
      flash[:error] = 'You can only like a post once'
    else
      like = Like.new
      like.user = current_user
      like.post = post
      like.save

      flash[:notice] = 'Thank you for liking the post'
    end

    redirect_to view_context.link_to_post_in_thread(post)
  end

  def destroy
    post = Post.find params[:id]
    like = post.likes.filter_by_user(current_user.id).first

    authorize! :delete, like

    like.destroy
    redirect_to view_context.link_to_post_in_thread(post), :notice => 'Your like has been removed'
  end
end