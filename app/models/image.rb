class Image < ActiveRecord::Base
  require 'digest/crc32'

  belongs_to :post, :counter_cache => true
  belongs_to :board_thread, :counter_cache => :images_count
  belongs_to :user, :counter_cache => true

  mount_uploader :image, ImageUploader

  after_save :process_image
  after_destroy :update_hierarchy

  def process_image
    update_columns(name: File.basename(image.to_s)) unless name
    update_columns(sha1_digest: Digest::SHA1.hexdigest(File.read(image.current_path))) unless sha1_digest
    update_columns(md5_digest: Digest::MD5.hexdigest(File.read(image.current_path))) unless md5_digest
    update_columns(crc32: Digest::CRC32.hexdigest(File.read(image.current_path))) unless crc32

    update_exif

    update_columns(processed: true)
  end

  def update_exif
    begin
      exif_reader = EXIFR::JPEG.new(image.current_path)
      if exif_reader.exif?
        update_column(:exif_created_at, exif_reader.date_time)
        update_column(:exif_camera, exif_reader.model)
        update_column(:exif_exposure, exif_reader.exposure_time.to_s)
        update_column(:exif_f_stop, exif_reader.f_number.to_f.to_s)
        update_column(:exif, true)
      else
        update_column(:exif, false)
      end
    rescue
      update_column(:exif, false)
    end
  end

  def update_hierarchy
    post.touch
    board_thread.touch
  end

  def class_thumbs
    css = 'border thumb'
    css += ' free' if board_thread.free_download
    css
  end

  def next
    thread = post.board_thread
    thread.images.where('images.id > ?', id).order('images.id asc').first
  end

  def previous
    thread = post.board_thread
    thread.images.where('images.id < ?', id).order('images.id desc').first
  end

  def send_filename(type)
    if type == :full
      name
    else
      "#{type}_#{id}.#{File.extname(image.to_s)}"
    end
  end

  def verification_line(format)
    return '' unless md5_digest
    case format
      when 'md5'
        "#{md5_digest}  #{board_thread.title}/#{name}\n"
      when 'sha1'
        "#{sha1_digest}  #{board_thread.title}/#{name}\n"
      when 'csv'
        "#{name},#{image.size},#{crc32},\\#{board_thread.title}\\,#{''}\r\n"
      when 'sfv'
        "#{name} #{crc32}\r\n"
      else
        ''
    end
  end

  handle_asynchronously :process_image
end
