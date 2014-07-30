class HomeController < ApplicationController
  respond_to :html
  skip_authorization_check

  def index
    add_to_crumbs nil
    @last_threads = BoardThread.order('updated_at desc').includes(:name_space, :posts).includes(:name_space, :posts).take(20)

    @intro_wiki  = RedCloth.new(Wiki.find_by_name('Homepage').last_revision.content).to_html
    @news_wiki = RedCloth.new(Wiki.find_by_name('News').last_revision.content).to_html
  end

  def access_denied
    add_to_crumbs ["Access Denied", access_denied_url]
    render :status => 403
  end
end
