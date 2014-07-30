class SearchesController < ApplicationController
  respond_to :html

  def search_text
    add_to_crumbs ['Search', search_text_path]
    authorize! :search, nil

    @search = params[:q]

    @results = Post.with_query(@search).paginate(:page => params[:page], :per_page => 10)
  end

  def search_image
    add_to_crumbs ['Image Search', search_image_path]
    authorize! :search, nil

    @hashes = []
    if params[:hashes]
      @hashes = params[:hashes].split(',').map(&:strip)
    end
    if params[:images]
      params[:images].each do |im|
        if im.respond_to?(:read)
          @hashes << Digest::SHA1.hexdigest(im.read)
        elsif im.respond_to?(:path)
          @hashes << Digest::SHA1.hexdigest(File.read(im.path))
        else
          logger.error "Bad file_data: #{im.class.name}: #{im.inspect}"
        end
      end
    end
    @search = @hashes.join(', ')

    @board_threads = BoardThread.joins(:images).where('images.sha1_digest' => @hashes)

    @results = @board_threads.paginate(:page => params[:page], :per_page => 2)
  end

  def search_fills
    add_to_crumbs ['Fills Search', search_fills_path]
    authorize! :search, nil

    return unless params[:verify]

    search_file = params[:verify].open
    file_extension = File.extname(params[:verify].original_filename)
    @hash_type = get_hash_type(file_extension)

    @results = []
    search_file.each do |line|
      next if file_extension == '.sfv' and line.start_with?(';')
      result = {}
      result[:hash] = get_hash(line, file_extension)
      result[:local] = get_filename(line, file_extension)
      result[:image] = Image.where(@hash_type => result[:hash]).first
      @results << result
    end
  end

  private
  def search_with_hash(hash_type, hash)
    case hash_type
      when
      Image.where()
    end
  end
  def get_hash_type(file_extension)
    case file_extension
      when '.csv'
        return :crc32
      when '.sfv'
        return :crc32
      when '.md5'
        return :md5_digest
      when '.sha1'
        return :sha1_digest
    end
  end

  def get_hash(line, file_extension)
    case file_extension
      when '.csv'
        line.split(',')[2].strip
      when '.sfv'
        line[-10, 9].strip
      when '.md5'
        line[0, 32]
      when '.sha1'
        line[0, 40]
    end
  end

  def get_filename(line, file_extension)
    case file_extension
      when '.csv'
        line.split(',')[0].strip
      when '.sfv'
        line[0..-10].strip
      when '.md5'
        File.basename(line[34..-1]).strip
      when '.sha1'
        File.basename(line[40..-1]).strip
    end
  end
end
