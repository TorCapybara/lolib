class ApplicationController < ActionController::Base

  #include ActionView::Helpers::UrlHelper

  protect_from_forgery
  check_authorization
  after_filter :aggregate_statistic
  before_filter :check_browser

private
  rescue_from CanCan::AccessDenied do |exception|
    #render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
    flash[:error] = exception.message
    redirect_to access_denied_url
  end

  def check_browser
    if request.user_agent =~ /android|ipod|iphone|ipad|iemobile|blackberry|opera mini/i
      unless  current_page?(access_denied_url)
        redirect_to access_denied_url
      end
    end
  end

  def default_url_options
    super
  end

  def logged_in?
    current_user != User.find_by_name('anonymous')
  end
  
  def current_user
    begin
      return User.where(:id => session[:user_id]).includes(:role).first if session[:user_id]
    rescue
    end
    return User.where(:name => 'anonymous').includes(:role).first
  end

  def interesting_referer?(request)
    return false if request.referer == nil or request.referer == ''
    return false if request.referer =~ /#{request.host}/i
    true
  end

  def aggregate_statistic
    collect_referer
    current_user.update_column(:last_online, Time.now) if logged_in?
    return

    if response.stream.is_a? ActionDispatch::Response::Buffer
      Statistics.increment_counter(:counter, statistic_model('hit', 'global'))
      Statistics.increment_counter(:counter, statistic_model('hit', Date.today))
    else
      image_type = response.request.path_parameters[:type]

      Statistics.increment_counter(:counter, statistic_model('image_' + image_type, 'global'))
      Statistics.increment_counter(:counter, statistic_model('image_' + image_type, Date.today))
    end
  end

  def collect_referer
    if interesting_referer? request
      session[:interesting_referer] = request.referer
      ping_back = PingBack.find_by_referer(request.referer)
      unless ping_back
        ping_back = PingBack.create :referer => request.referer, :counter => 1, :visible => false
        ping_back.save
      else
        PingBack.increment_counter(:counter, ping_back)
        ping_back.touch
      end
    end

    if session[:interesting_referer] and logged_in?
      current_user.referers << Referer.create(:name => session[:interesting_referer])
      session[:interesting_referer] = nil
    end
  end

  def statistic_model type, scope
    statistic = Rails.cache.fetch("statistic_model_#{scope}_#{type}") { Statistics.where(:scope => scope, :counter_type => type).first }
    unless statistic
      Rails.cache.delete("statistic_model_#{scope}_#{type}")
      statistic = Statistics.create :scope => scope, :counter_type => type
      statistic.save
    end
    statistic
  end

  def add_to_crumbs object
    unless object
      @breadcrumbs = Hash.new
      if current_user.css_level == 'none'
        @breadcrumbs['Home'] = root_path
      else
        @breadcrumbs["<i class=\"fa fa-home fa-lg\"></i>"] = root_path
      end
    else
      case object
        when Array
          add_to_crumbs nil
          @breadcrumbs[object[0]] = object[1]
        when Image
          add_to_crumbs(object.board_thread)
          @breadcrumbs[object.name] =  [object]
        when Post
          add_to_crumbs(object.board_thread)
          if object.new_record?
            @breadcrumbs['New Post'] = ''
          else
            @breadcrumbs["Post #{object.id}"] = object
          end
        when BoardThread
          add_to_crumbs(object.name_space)
          @breadcrumbs[object.title || 'New Thread'] = [object]
        when NameSpace
          if (object.parent_space)
            add_to_crumbs object.parent_space
          else
            add_to_crumbs ['Boards', name_spaces_path]
          end
          @breadcrumbs[object.name] = name_space_path(object)
        when Wiki
          add_to_crumbs ['Wiki', wikis_path]
          @breadcrumbs[object.name || 'New Wiki'] = [object]
        when User
          add_to_crumbs ['User', users_path]
          @breadcrumbs[object.name] = [object]
        when PrivateMessage
          @private_message.sender == current_user ?  add_to_crumbs(['PM Outbox', outbox_private_messages_path]) : add_to_crumbs(['PM Inbox', private_messages_path])
          @breadcrumbs[object.subject || 'New Message'] = [object]
        when Warning
          add_to_crumbs(object.user)
          @breadcrumbs['Warning'] = [object]
        when Role
          add_to_crumbs ['Roles', roles_path]
          @breadcrumbs[object.name] = [object]
        when Report
          add_to_crumbs(['Reported Posts', reports_path])
          @breadcrumbs['Report ' + object.id.to_s] = [object]
        else
          add_to_crumbs nil
          @breadcrumbs['Unknown'] = '#'
      end
    end
  end


  helper_method :current_user, :logged_in?, :authenticate?, :users_online, :statistic_model
end
