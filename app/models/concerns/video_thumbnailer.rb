module VideoThumbnailer
  extend ActiveSupport::Concern

  module ClassMethods
    def create_contact_sheet(fast)
      system screenshot fast
    end

    def screenshot(fast)
      if fast
        command = "#{Rails.configuration.encoder} -y -ss #{time} -i #{video_path} -s 400x300 -vframes 1 -f  image2 -aspect 1.33333333333333 #{path}"
      else
        command = "#{Rails.configuration.encoder} -i #{video_path} -y -ss #{time} -s 400x300 -vframes 1 -f  image2 -aspect 1.33333333333333 #{path}"
      end
      command
    end
  end
end