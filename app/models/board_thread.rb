class BoardThread < ActiveRecord::Base
  require 'RMagick'
  require 'zip'

  include FlagShihTzu

  self.per_page = 25

  has_flags 1 => :sticky,
            2 => :picture_freeze,
            3 => :closed,
            4 => :announced,
            5 => :index,
            6 => :free_download


  validates :title, :presence => true
  validates_associated :posts

  belongs_to :name_space
  belongs_to :user

  has_many :posts, :dependent => :destroy
  has_many :ratings
  has_many :images
  has_one :video

  accepts_nested_attributes_for :posts, :reject_if => proc { false }, :allow_destroy => true
  accepts_nested_attributes_for :video, :reject_if => proc { false }, :allow_destroy => true

  acts_as_indexed :fields => [:title]

  after_save :clean_up, :generate_sprites
  after_touch :clean_up, :generate_sprites

  def self.latest_threads_with_images
    threads = BoardThread.where('images_count > 0').index.includes(:images).order('updated_at desc').first(9)

    image_list = Magick::ImageList.new

    threads.each do |thread|
      image_list.push(Magick::Image.read(File.join(Rails::root, thread.images.last.image_url(:thumb))).first)
      image_list.push(Magick::Image.read(File.join(Rails::root, thread.images.first.image_url(:thumb))).first)
    end

    montage = image_list.montage {
      self.geometry = '60x60'
      self.tile = '18x1'
      self.compose = Magick::OverCompositeOp
      self.background_color = '#000000'
    }
    montage.write(File.join(Rails::root, 'public', 'latest.jpg'))
    threads
  end

  def generate_sprites
    return if images.none?

    image_list = Magick::ImageList.new
    begin
      images.each do |image|
        image_list.push(Magick::Image.read(File.join(Rails::root, image.image_url(:thumb))).first)
      end
    rescue
      return
    end

    images_count = images.count
    montage = image_list.montage {
      self.geometry = '60x60'
      self.tile = "#{[images_count, 20].min}x"
      self.compose = Magick::OverCompositeOp
      self.background_color = '#000000'
    }

    FileUtils.mkdir_p(File.dirname(sprites))
    montage.write(sprites)
  end

  def sprites
    File.join(Rails::root, 'uploads', 'sprites', "sprites_#{id}.jpg")
  end

  def image_sample
    Rails.cache.fetch("thread_image_sample_#{id}") do
      count = images.count
      if count < 5
        images.to_a
      else
        result = []
        result << images.first
        result << images.offset(count/3).take(1)
        result << images.offset(2*count/3).take(1)
        result << images.last
      end
    end
  end

  def update_image_offsets
    current_offset = 0
    posts.each do |post|
      post.update_column(:image_offset, current_offset)
      current_offset += post.images.count
    end
  end


  def clean_up
    Rails.cache.delete("thread_image_sample_#{id}")
    File.delete(zip_file_name) if File.exist? zip_file_name
    update_image_offsets
  end

  def verification_header(format)
    case format
      when 'md5', 'sha1','csv'
        ''
      when 'sfv'
        "; Created by lolib\r\n" <<
        "; \r\n"
      else
        ''
    end
  end

  def verification_file(format)
    content = verification_header(format)
    images.each do |image|
      content <<= image.verification_line(format)
    end
    content
  end

  def zip_file_name
     File.join(Rails::root, 'uploads', 'zips', 'board_thread', "#{id}.zip")
  end

  def create_zip
    FileUtils.mkdir_p(File.dirname(zip_file_name))
    File.delete(zip_file_name) if File.exist? zip_file_name

    Zip::File.open(zip_file_name, Zip::File::CREATE) do |zip_file|
      images.each do |image|
        begin
          zip_file.add(File.join(title, image.name), File.join(Rails::root, image.image_url(nil)))
        rescue Zip::ZipEntryExistsError
          zip_file.add(File.join(title, image.id.to_s, image.name), File.join(Rails::root, image.image_url(nil)))
        end
      end
      create_info_file(zip_file)
    end
    FileUtils.chmod(0644, zip_file_name)
  end

  def create_info_file(zip_file)
    zip_file.get_output_stream("Info-#{title}.txt") do |os|
      os.puts 'This zip file is generated by the lolib board!'
      os.puts ''
      os.puts 'Full set name: ' + name_space.full_path + ' / ' + title
      posts.each do |post|
        os.puts ('-' * 80)
        os.puts post.text
      end
    end
  end

  handle_asynchronously :create_zip

end
