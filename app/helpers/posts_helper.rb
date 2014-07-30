module PostsHelper
  def format_post(text)
    safe_text = simple_format(sanitize(text, tags: %w(), attributes: %w(q)))
    safe_text = remove_http("#{safe_text}")
    safe_text = parse_board_thread("#{safe_text}")
    safe_text = parse_post("#{safe_text}")
    safe_text = parse_name_space("#{safe_text}")
    safe_text = parse_wiki("#{safe_text}")
    safe_text = parse_users("#{safe_text}")
    safe_text = parse_link("#{safe_text}")
    safe_text = parse_image("#{safe_text}")
    safe_text = parse_bb(safe_text)
    safe_text = parse_smileys(safe_text)
    return safe_text.html_safe
  end

  def remove_http(text)
    text.gsub(/https?:\/\/\S+/, '[External Link removed]')
  end

  def parse_object(text)

  end

  def parse_board_thread(text)
    text.gsub(/\[board_threads\/([0-9]*)\]/i) do |match|
      thread = BoardThread.find_by_id("#{$1}".to_i)
      if thread and can? :read, thread
        link_to((thread.name_space.full_path + ' / ' + thread.title + ' ').html_safe + fa_icon('fa-comments') , thread) +
            link_to(fa_icon('fa-picture-o'), images_board_thread_path(thread)) +
            link_to(fa_icon('fa-link'), links_board_thread_path(thread))
      else
        "<strike>board_threads/#{$1}</strike>"
      end
    end
  end

  def parse_post(text)
    text.gsub(/\[posts\/([0-9]*)\]/i) do |match|
      post = Post.find_by_id("#{$1}".to_i)
      if post and can? :read, post
        link_to((post.board_thread.name_space.full_path + ' / ' + post.board_thread.title + ' / Post ' + post.id.to_s).html_safe, post)
      else
        "<strike>posts/#{$1}</strike>"
      end
    end
  end

  def parse_link(text)
    text.gsub(/\[links\/([0-9]*)\]/i) do |match|
      link = Link.find_by_id("#{$1}".to_i)
      if link and can? :read, link
        '<em class="tooltip-container">' + link_to(("#{link.uri} (#{link.name})").html_safe, redirect_link_path(link)) + '<span class="tooltip tooltip-style1">' + link.description + '</span></em>'
      else
        "<strike>posts/#{$1}</strike>"
      end
    end
  end

  def parse_name_space(text)
    text.gsub(/\[name_spaces\/([0-9]*)\]/i) do |match|
      name_space = NameSpace.find_by_id("#{$1}".to_i)
      if name_space and can? :read, name_space
        link_to((name_space.full_path + ' ').html_safe + fa_icon('fa-list') , name_space)  +
        link_to(fa_icon('fa-picture-o'), preview_name_space_path(name_space))
      else
        "<strike>name_space/#{$1}</strike>"
      end
    end
  end

  def parse_wiki(text)
    text.gsub(/\[wikis\/(.*?)\]/i) do |match|
      wiki = Wiki.find_by_name($1)
      if wiki and can? :read, wiki
        link_to(('Wiki / ' + wiki.name + ' ').html_safe + fa_icon('fa-file-text-o'), wiki)
      else
        "<strike>wiki/#{$1}</strike>"
      end
    end
  end

  def parse_users(text)
    text.gsub(/\[users\/(.*?)\]/i) do |match|
      user = User.find($1)
      if user and can? :read, user
        link_to(('User / ' + user.name + ' ').html_safe + fa_icon('fa-user'), user)
      else
        "<strike>users/#{$1}</strike>"
      end
    end
  end

  def parse_image(text)
    text.gsub(/\[images\/([0-9]*)\]/i) do |match|
      image = Image.find_by_id("#{$1}".to_i)
      if image and can? :read, image
        link_to(image_tag(get_image_path(image, :thumb), :alt => image.name, :title => image.name, :class => image.class_thumbs), image)
      else
        "<strike>images/#{$1}</strike>"
      end
    end
  end

  def parse_bb(text)
    text.gsub!(/\[b\](.*?)\[\/b\]/im, '<strong>\1</strong>')
    text.gsub!(/\[i\](.*?)\[\/i\]/im, '<em>\1</em>')
    text.gsub!(/\[u\](.*?)\[\/u\]/im, '<u>\1</u>')
    text.gsub(/\[s\](.*?)\[\/s\]/im, '<strike>\1</strike>')
  end

  def parse_smileys(text)
    text.gsub!(/(\s):\$/, '\1' + image_tag(asset_path 'bb/blush.png'))
    text.gsub!(/(\s)\|-?\)/, '\1' + image_tag(asset_path 'bb/closed.png'))
    text.gsub!(/(\s)8-?\)/, '\1' + image_tag(asset_path 'bb/cool.png'))
    text.gsub!(/(\s):'-?\(/, '\1' + image_tag(asset_path 'bb/cry.png'))
    text.gsub!(/(\s)[>3]:-?\)/, '\1' + image_tag(asset_path 'bb/evil.png'))
    text.gsub!(/(\s):-?\|/, '\1' + image_tag(asset_path 'bb/fine.png'))
    text.gsub!(/(\s):-?\(/, '\1' + image_tag(asset_path 'bb/frown.png'))
    text.gsub!(/(\s)\*glasses\*/, '\1' + image_tag(asset_path 'bb/glasses.png'))
    text.gsub!(/(\s):-?D/, '\1' + image_tag(asset_path 'bb/grin.png'))
    text.gsub!(/(\s):-?[oO]/, '\1' + image_tag(asset_path 'bb/shock.png'))
    text.gsub!(/(\s)\*sick\*/, '\1' + image_tag(asset_path 'bb/sick.png'))
    text.gsub!(/(\s):-?\)/, '\1' + image_tag(asset_path 'bb/smile.png'))
    text.gsub!(/(\s):-?[pP]/, '\1' + image_tag(asset_path 'bb/tongue.png'))
    text.gsub(/(\s);-?\)/, '\1' + image_tag(asset_path 'bb/wink.png'))
  end

  def link_to_post_in_thread(post)
    if post
      board_thread_path(post.board_thread) + '#post-' + post.id.to_s
    else
      ''
    end
  end
end
