Rails.application.routes.draw do
  # Root Controller
  root :to => 'home#index'

  #access_denied
  get 'access_denied' => 'home#access_denied', :as => 'access_denied'

  # User interaction
  get 'logout' => 'sessions#destroy', :as => 'logout'
  get 'login' => 'sessions#new', :as => 'login'
  get 'signup' => 'users#new', :as => 'signup'
  get 'profile' => 'users#show', :id => 'me'
  get 'my_posts' => 'users#show_posts', :id => 'me'

  resource :home, :only => [:index]

  resources :users do
    member do
      get 'delete'
      get 'create_invitation'
      post 'create_invitation'
      get 'trust'
      post 'trust'
      get 'change_password'
      patch 'change_password'
      get 'change_settings'
      patch 'change_settings'
      get 'posts' => 'users#show_posts'
      get 'referers' => 'users#show_referers'
      get 'pm' => 'private_messages#send_to'
    end
    resources :warnings, :only => [:new, :create, :edit, :update, :show], shallow: true
  end
  resources :sessions, :only => [:new, :create, :destroy]
  resources :roles, :only => [:index, :show]

  resources :name_spaces, :only => [:new, :create, :index, :show, :edit, :update] do
    member do
      get 'new_sub' => 'name_spaces#new', :as => 'new_sub'
      get 'preview' => 'name_spaces#show_images'
      get 'verify' => 'name_spaces#download_verification'
    end

  end

  resources :board_threads do
    member do
      get 'images' => 'board_threads#show_images'
      get 'links' => 'board_threads#show_links'
      get 'new_thread' => 'board_threads#new', :as => 'new_thread'
      get 'zip' => 'board_threads#download'
      get 'sprites'
      get 'verify' => 'board_threads#download_verification'
    end
    collection do
      get 'preview' => 'board_threads#index_images'
    end
    resources :posts, :only => [:new, :create] do
      member do
        get 'sub' => 'posts#new', :as => :sub
      end
    end
  end
  resources :posts, :only => [:edit, :update, :show, :destroy] do
    member do
      get 'report'
      get 'zip' => 'posts#download'
      get 'like' => 'likes#create'
      get 'dislike' => 'likes#destroy'
      patch 'move'  => 'posts#move'
    end
  end

  resources :images, :only => [:show, :destroy, :edit, :update] do
    member do
      get 'get/:type' => 'images#download', :as => :get
      get 'avatar/:type' => 'images#get_avatar', :as => :get_avatar
    end
  end

  resources :videos, :only => [:index, :show, :create] do
    member do
      get 'new_video' => 'videos#new', :as => 'new_video'
      get 'get' => 'videos#download', :as => :get
      get 'cs' => 'videos#download_contact_sheet', :as => :get_cs
    end
  end

  resources :reports, :only => [:index, :show, :create, :edit, :update] do
    member do
    end
  end

  get 'search/text' => 'searches#search_text'
  get 'search/image' => 'searches#search_image'
  post 'search/image' => 'searches#search_image'
  get 'search/fills' => 'searches#search_fills'
  post 'search/fills' => 'searches#search_fills'

  resources :private_messages, :only => [:index, :show, :new, :create] do
    member do
      get 'reply' => 'private_messages#reply'
    end
    collection do
      get 'outbox'
    end
  end

  resources :wikis

  resources :links, :except => [:show] do
    member do
      get 'redirect'
      get 'delete'
    end
  end

  resources :likes, :only => [:index]

  resources :statistics, :only => [:index, :show]
end
