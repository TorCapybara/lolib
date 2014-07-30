class Video < ActiveRecord::Base
  require 'RMagick'

  belongs_to :board_thread
  belongs_to :user

  mount_uploader :video, VideoUploader

  after_save :process_video

  before_destroy :remove_contact_sheet

  def contact_sheet_path
    if video?
      File.join(File.dirname(video.current_path), 'cs.jpg')
    else
      nil
    end
  end

  def process_video(full_processing = false)
    return unless video?
    movie = FFMPEG::Movie.new(video.current_path)

    update_columns(name: File.basename(video.current_path))
    update_columns(size: File.size(video.current_path))
    update_columns(sha1_digest: Digest::SHA1.hexdigest(File.read(video.current_path)))
    update_columns(md5_digest: Digest::MD5.hexdigest(File.read(video.current_path)))

    return unless movie.valid?

    update_columns(duration: movie.duration) if movie.duration
    update_columns(bit_rate: movie.bitrate) if movie.bitrate
    update_columns(video_stream: movie.video_stream)
    update_columns(video_codec: movie.video_codec)
    update_columns(colorspace: movie.colorspace)
    update_columns(width: movie.width) if movie.width
    update_columns(height: movie.height) if movie.height
    update_columns(frame_rate: movie.frame_rate) if movie.frame_rate
    update_columns(audio_stream: movie.audio_stream)
    update_columns(audio_codec: movie.audio_codec)
    update_columns(sample_rate: movie.audio_sample_rate) if movie.audio_sample_rate
    update_columns(audio_channels: movie.audio_channels) if movie.audio_channels

    contact_sheet_title = name
    contact_sheet_title << " | #{ApplicationController.helpers.number_to_human_size(size)}"
    contact_sheet_title << " | #{width}x#{height}"
    contact_sheet_title << " | #{Time.at(movie.duration).utc.strftime("%H:%M:%S")}" if movie.duration
    contact_sheet_title << " | by lol*IB*"

    # create thumbnails
    number_of_thumbs = 16
    interval = movie.duration / number_of_thumbs

    # montage thumbs
    image_list = Magick::ImageList.new

    0.upto(number_of_thumbs - 1).each do |i|
      path = File.join(File.dirname(video.current_path), 'thumb_' + i.to_s + '.jpg')
      movie.screenshot(path, {seek_time: (interval / 2 + i * interval), resolution: '400x400'}, preserve_aspect_ratio: :width)
      image_list.push(Magick::Image.read(File.join(File.dirname(video.current_path), 'thumb_' + i.to_s + '.jpg')).first)
    end

    montage = image_list.montage {
      self.geometry = '320x240+7+5'
      self.gravity = Magick::CenterGravity
      self.border_width = 2
      self.tile = Magick::Geometry.new(4, 4)
      self.compose = Magick::OverCompositeOp
      self.background_color = "white"
      self.shadow = true
      self.title = contact_sheet_title
    }
    montage.write(contact_sheet_path)

    0.upto(number_of_thumbs - 1) do |i|
      path = File.join(File.dirname(video.current_path), 'thumb_' + i.to_s + '.jpg')
      if File.exist?(path)
        File.delete(path)
      end
    end

    update_columns(processed: true)
  end

  handle_asynchronously :process_video

  private
  def remove_contact_sheet
    if contact_sheet_path and File.exist?(contact_sheet_path)
      File.delete(contact_sheet_path)
    end
  end
end
