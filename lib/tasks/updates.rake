namespace :updates do
  desc 'Calculate Image Offsets'
  task :calculate_image_offsets => :environment do
    BoardThread.find_each do |thread|
      thread.update_image_offsets
    end
  end

  desc 'Update Exif information'
  task :cache_exif => :environment do
    Image.find_each do |image|
      puts image.name
      image.update_exif
    end
  end

end
