Playtime::Application.routes.draw do
  get "shows/:year/:month" => "shows#index", :as => :month,
    :constraints => { year: /\d{4}/, month: /\d{1,2}/ }
  put "shows" => "shows#batch", :as => :update_shows
  
  resources :notes,
    :path => "shows/:year/:month/:day/notes",
    :constraints => { year: /\d{4}/, month: /\d{1,2}/, day: /\d{1,2}/ },
    :only => [ :index, :create, :update, :destroy ]

  get    'login'  => 'sessions#current', as: :current_session
  post   'login'  => 'sessions#login',   as: 'login'
  delete 'logout' => 'sessions#logout',  as: 'logout'
  
  root to: 'playtime#index'
end
