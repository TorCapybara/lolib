module VideosHelper
  def video_link(video, button = false)
    link_class = button ? 'button' : ''
    if video and video.processed
      if button
        if can?(:read, video)
          link_to(fa_icon('fa-film') + ' Download Video', get_video_path(video), class: 'button')
        end
      else
        link_to_if(can?(:read, video), video.name, get_video_path(video))
      end
    else
      if button
        ''
      else
        if video.video?
          link_to 'Not Ready', '', class: link_class
        else
          link_to 'Video Broken', '', class: link_class
        end
      end
    end
  end
end
