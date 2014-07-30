include CarrierWave::RMagick


class ImagesController < ApplicationController
  respond_to :html

  before_action :setup_action, :only => [:show, :edit, :update, :delete, :destroy]

  def show
    authorize! :read, @image

    @r_image = Magick::Image.read(File.join(Rails::root, @image.image_url))
  end

  def edit
    authorize! :update, @image
  end

  def update
    authorize! :update, @image

    if @image.update_attributes(params.require(:image).permit(:name))
      Rails.cache.delete("cache_image_#{@image.id}")
      @image.board_thread.touch
      flash[:notice] = 'Image successfully renamed'
      redirect_to @image
    else
      render :edit
    end
  end

  def destroy
    authorize! :delete, @image

    post = @image.post
    @image.destroy

    redirect_to post
  end

  def download
    id = params[:id]
    image = Rails.cache.fetch("cache_image_#{id}") { Image.find(id) }
    Rails.cache.delete("cache_image_#{id}") unless image.image_url()
    authorize! :read, image

    fresh_when(image)

    type = params[:type].to_sym

    if (type == :thumb) or can?(:download, image)
      send_file File.join(Rails::root, image.image_url(type == :full ? nil : type)), :x_sendfile => true, :disposition => 'inline', :filename => (image.send_filename(type))
      if type == :full or type == :design
        Image.increment_counter(:views, image.id)
        User.increment_counter(:today_views, current_user.id)
      end
      if type == :full
        current_user.update_column(:byte_download, current_user.byte_download + image.image.size)
        User.increment_counter(:image_download, current_user.id)
      end
    else
      redirect_to asset_path('access_denied.jpg') , :status => 403
    end
  end

  def get_avatar
    user = User.find(params[:id])
    type = params[:type].to_sym

    authorize! :read, Image

    send_file File.join(Rails::root, user.avatar_url(type == :full ? nil : type)), :x_sendfile=>true, :disposition => 'inline', :filename => "avatar_#{user.id}.#{File.extname(user.avatar.to_s)}"
  end

private

  def setup_action
    @image = Image.find(params[:id])
    add_to_crumbs(@image)
  end

end
