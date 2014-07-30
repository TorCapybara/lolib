def reload_magic
  eval(File.read('magic.rb'))
end

def duplicate_threads
  duplicates = 0
  File.open("duplicates.txt", "w") do |out|
    BoardThread.find_each do |t|
      dupes = duplicate_thread t
      if dupes.count > 1
        duplicates += 1
        puts '-----------------------------------------------------------'
        out.puts '-----------------------------------------------------------'
        dupes.each do |t_id|
          t = BoardThread.find t_id
          puts "#{t.id}: #{t.name_space.full_path} / #{t.title}"
          out.puts "#{t.id}: #{t.name_space.full_path} / #{t.title}"
        end
      end
    end
    puts '=================================='
    out.puts '=================================='
    puts "Number of Duplicates: #{duplicates}"
    out.puts "Number of Duplicates: #{duplicates}"
    puts "Created at: #{DateTime.now.to_s}"
    out.puts "Created at: #{DateTime.now.to_s}"
  end
  duplicates
end


def duplicate_thread thread
  ignored_boards = [1, 2, 3, 20, 21, 22, 23, 28, 31, 76, 293, 387, 434, 926, 985]
  ignored_threads = [4528, 8141, 29942, 29943, 29944,36336, 38708]
  ignore_sets = [ [2675, 2680].to_set, [28716, 28692].to_set, [20433, 20438, 20453, 20457, 20464, 20472].to_set, [20072, 24305].to_set]

  result = Set.new
  return result if ignored_boards.include?(thread.name_space_id) or ignored_threads.include?(thread.id)
  thread.images.each do |image|
    dup = Image.where('sha1_digest = ?', image.sha1_digest)
    dup.each do |d|
      unless ignored_boards.include?(d.board_thread.name_space_id) or ignored_threads.include?(d.board_thread_id)
        result << d.board_thread_id
      end
    end
  end
  ignore_sets.each do |set|
    return Set.new if set == result
  end
  result
end

def has_duplicate image
  result = Image.where('sha1_digest = ?', image.sha1_digest)
  result.each do |i|
    if image != i
      return true
    end
  end
  false
end

def remove_duplicate_images post_id
  post = Post.find post_id
  deleted = 0
  post.images.each do |i|
    if has_duplicate(i)
      puts "Image: #{i.image} deleted"
      deleted += 1
      i.destroy
    end
  end
  post.board_thread.generate_sprites
  deleted
end

def repair_threads(all=false)
  if all
    threads = BoardThread.all
  else
    threads = BoardThread.where('updated_at > ?', DateTime.now - 48.hours)
  end
  threads.each do |t|
    print '.'
    if t.posts.count == 0
      t.destroy
      puts "Thread empty!"
      next
    end
    unless t.title == t.title.strip
      t.title = t.title.strip
      t.title = t.title.gsub('  ', ' ')
      t.save
      puts "Spaces removed: #{t.title}"
    end
    unless t.index == t.name_space.index
      t.index = t.name_space.index
      t.save
      puts "Index status fixed: #{t.title}"
    end
    unless t.created_at == t.posts.first.created_at
      t.created_at = t.posts.first.created_at
      t.save
      puts "Created time fixed: #{t.title}"
    end
    unless t.updated_at == t.posts.last.created_at
      t.updated_at = t.posts.last.created_at
      t.save
      puts "Updated time fixed: #{t.title}"
    end
  end
  nil
end

def move_post_to_thread post_id, thread_id, remove_parent=true
  p = Post.find post_id
  p.child_posts.each do |c|
    move_post_to_thread c.id, thread_id, false
  end
  p.images.each do |i|
    i.board_thread_id = thread_id
    i.save
  end
  p.board_thread_id = thread_id
  p.parent_id = nil if remove_parent
  p.save
  BoardThread.find(thread_id).generate_sprites
  nil
end

def safe_delete_user user
  return unless user.is_a? User
  user.inbox_messages.destroy_all
  user.outbox_messages.destroy_all
end

def sort_name_space id
  n = NameSpace.find id
  n.child_spaces.order('name').each_with_index do |s, i|
    s.sort_order = i * 10
    s.save
  end
  nil
end

def sort_name_spaces
  NameSpace.all.each do |n|
    sort_name_space n.id
  end
  nil
end

def leecher_list n
  User.all.order('byte_download desc').first(n).each do |u|
    puts "DL: #{helper.number_to_human_size(u.byte_download)}, #{u.id}:#{u.name}, P/I:#{u.posts.count}/#{u.images.count}"
  end
  nil
end

def clear_ping_back
  unify = PingBack.find_by_referer 'somereferer'
  PingBack.find_each do |p|
    if p.referer =~ /http:..[0-9][0-9][0-9][0-9]/ or p.referer =~ /lolib\.onion/ 
      puts p.id
      p.delete
    end
    if p != unify and p.referer =~ /lolib2qi7bmnlunt.onion/
      unify.counter += p.counter
      p.delete
    end
  end
  unify.save
  Referer.find_each do |p|
    if p.name =~ /http:..[0-9][0-9][0-9][0-9]/ or p.name =~ /lolib\.onion/ or p.name =~ /lolib2qi7bmnlunt.onion/
      puts p.id
      p.delete
    end
  end
  nil
end

def split_thread id
  t = BoardThread.find id
  t.posts.offset(1).each do |p|
    th = BoardThread.new
    th.title = t.title
    th.user = t.user
    th.name_space = t.name_space
    th.save
    move_post_to_thread p.id, th.id
  end
  nil
end

def move_images from_post_id, to_post_id, pattern
  from = Post.find from_post_id
  from.images.each do |i|
    if i.name =~ pattern
      i.post_id = to_post_id
      i.save
    end
  end
  from.board_thread.generate_sprites
  nil
end

def split_post post_id, num
  o = Post.find post_id
  2.upto(num) do |i|
    p = Post.new
    p.user_id = o.user_id
    p.board_thread_id = o.board_thread_id
    p.text = "This post was split, this is Part #{i} of #{num}: " + o.text
    p.save
    p.created_at = o.created_at 
    p.updated_at = o.updated_at 
    p.save
  end
end

def set_three_zero n
  n.board_threads.each do |t|
    unless t.title =~ /[0-9][0-9][0-9]/ or t.title =~ /custom/i or t.title =~ /bonus/i
      t.title = t.title.gsub('Set ', 'Set 0')
    end
    t.save
  end
  nil
end

def set_fix_set n
  n.board_threads.each do |t|
    unless t.title =~ /custom/i or t.title =~ /bonus/i
      t.title = t.title.gsub(/.*set/i, 'Set')
      t.title = t.title.gsub('.', '')
      t.save
    end
  end
  nil
end

def user_activity
  r = Role.find 3
  r.users.order('byte_download DESC').first(50).each do |u|
    i = Invitation.where('user_id = ?',u.id).first
    if i
      before = u.posts.where('created_at < ?',i.created_at).count
      all = u.posts.count
      puts "#{u.id}:#{u.name}:#{u.byte_download} has before:#{before} after:#{all-before}"
    else
      puts "#{u.id}:#{u.name} has no invitation"
    end
  end
  nil
end

def set_board_access_standard proto
  NameSpace.all.each do |n|
    puts n.full_path
    n.board_accesses.each do |ba|
      puts '* ' + ba.role.name
      base = proto.board_accesses.filter_by_role(ba.role_id).first
      puts "old: #{ba.flags} --> new: #{base.flags}"
      ba.flags = base.flags
      ba.save
    end
  end
  nil
end

def standard_board_access
  sba = {}
  sba[1] = 0 
  sba[2] = 7
  sba[3] = 31
  sba[4] = 95
  sba[5] = 0
  sba[6] = 0
  sba[7] = 31
  return sba
end


def check_board_access(detail = false, id = nil)
  sba = standard_board_access
  if id
    tree = [[NameSpace.find(id).full_path, id]]
  else
    tree = NameSpace.select_tree
  end
  tree.each do |full_path, id|
    n = NameSpace.find id
    wrong = !n.index
    n.board_accesses.each do |ba|
      if sba[ba.role_id] != ba.flags
        if detail
          puts 'Deviant Role Access: '
          puts ' * ' + full_path
          puts ' * ' + ba.role.name 
          puts ' * Standard Access: ' + sba[ba.role_id].to_s + ' / Board Access: ' + ba.flags.to_s
        else
          wrong = true
        end
      end
    end
    if wrong
      puts "#{full_path} (#{id})"
    end
  end
  puts '*** check done ***'
end

def locktime j
  if j.locked_at
    return (j.locked_at - j.run_at).to_s
  end
  '' 
end

def list_jobs
  Delayed::Job.all.each do |j|
    
     
    if j.handler =~ /create_zip_without_delay/
      begin
        handle = YAML::load(j.handler)
        if handle.respond_to?(:title)
          puts "Thread #{handle.id}: #{handle.title} #{locktime j}"
        else
          puts "Post #{handle.id}"
        end
      end
    end
    if j.handler =~ /process_image_without_delay/
      begin
        handle = YAML::load(j.handler)
        puts "Image #{handle.id}: #{handle.image}"
      end
    end
  end
  nil
end

def rm_zip_jobs
  Delayed::Job.all.each do |j|
    if j.handler =~ /create_zip_without_delay/
      begin
        handle = YAML::load(j.handler)
        if handle.respond_to?(:title)
          puts "#{handle.id}: #{handle.title}"
        else
          puts "Post #{handle.id}"
        end
        j.destroy
      rescue
      end
    end
  end
  nil
end

def check_corruption file
  command = "avconv -loglevel warning -i #{file} -f null - > NUL"
  system command  
end

def create_thumbs(video, slow=false)
  number_of_thumbs = 16
  interval = video.duration / number_of_thumbs
  0.upto(number_of_thumbs - 1).each do |i|
    command = ''
    path = File.join(File.dirname(video.video.current_path), 'thumb_' + i.to_s + '.jpg')
    puts path;  
    if slow
      command = "avconv -y -i #{video.video.current_path} -ss #{interval / 2 + i * interval} -s 400x300 -vframes 1 -f image2 -aspect 1.3333333333333333 #{path}"
    else
      command = "avconv -y -ss #{interval / 2 + i * interval} -i #{video.video.current_path} -s 400x300 -vframes 1 -f image2 -aspect 1.3333333333333333 #{path}"
    end
    system command  
  end
  video.process_video_without_delay
end

def current_load
  IO.popen('uptime').each do |line|
    la = false
    line.chomp.split.each do |part|
      return part.chomp(',').to_f if la
      la = true if part == 'average:'
    end
  end
end

def clean_likes
  Like.all.each do |l|
    if Like.where('user_id = ? AND post_id = ?',l.user_id, l.post_id).count > 1
      print "*#{Like.where('user_id = ? AND post_id = ?',l.user_id, l.post_id).count - 1}"
      Like.where('user_id = ? AND post_id = ?',l.user_id, l.post_id).offset(1).destroy_all
    end
    if l.user == nil
      print "/"
      l.destroy
      next
    end
    if l.user.role_id == 1
      print "-"
      l.destroy
    end
  end
  nil
end


def fix_user_counts
  User.all.each do |u|
    pc = u.posts_count
    ic = u.images_count
    User.reset_counters(u.id, :images)
    User.reset_counters(u.id, :posts)
    v = User.find u.id
    if (pc != v.posts_count)
      puts "Posts count corrected for #{u.name} Before: #{pc} After: #{v.posts_count}"
    end
    if (ic != v.images_count)
      puts "Images count corrected for #{u.name} Before: #{ic} After: #{v.images_count}"
    end
    print '.'
  end
  nil
end

def fix_thread_counts
  BoardThread.all.each do |t|
    pc = t.posts_count
    ic = t.images_count
    BoardThread.reset_counters(t.id, :images)
    BoardThread.reset_counters(t.id, :posts)
    u = BoardThread.find t.id
    if (pc != t.posts_count)
      puts "Posts count corrected for #{t.name} Before: #{pc} After: #{u.posts_count}"
    end
    if (ic != t.images_count)
      puts "Images count corrected for #{t.name} Before: #{ic} After: #{u.images_count}"
    end
    print '.'
  end
  nil
end


def has_warning u, regexp
  u.warnings.each do |w|
    return true if w.reason =~ regexp
  end
  return false
end

def create_warning u, reason
  w = Warning.new
  w.moderator = User.find_by_name 'admin'
  w.user = u
  w.reason = reason
  w.save!
end

def delete_threads_in_board(id, all = false)
  n = NameSpace.find id
  n.board_threads.each do |t|
    puts "#{t.id}: #{t.title}"
    t.posts.each do |p|
      puts "Post #{p.id}"
      if all
        p.images.destroy_all
      else
        remove_duplicate_images p.id
      end
    end
    t.posts.destroy_all if all or t.images_count == 0
    t.destroy if all or t.images_count == 0
  end
  nil
end
