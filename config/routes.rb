Masquerade::Application.routes.draw do |map|

  resource :account do
    get :activate
    get :password
    put :change_password
    
    resources :personas do
      resources :properties
    end
    resources :sites do
      resources :release_policies
    end
    resource :yubikey_association
  end
  
  resource :session
  resource :password
  
  
  match "/forgot_password" => "passwords#new", :as => :forgot_password
  match "/reset_password/:id"  => "passwords#edit", :as => :reset_password
  
  match "/login" => "sessions#new", :as => :login
  match "/logout/:id" => "sessions#destroy", :as => :logout
  
  match "/server" => "server#index", :as => :server
  match "/server/decide" => "server#decide", :as => :decide
  match "/server/proceed" => "server#proceed", :as => :proceed
  match "/server/complete" => "server#complete", :as => :complete
  match "/server/cancel" => "server#cancel", :as => :cancel
  match "/server/seatbelt/config.:format" => "server#seatbelt_config", :as => :seatbelt_config
  match "/server/seatbelt/state.:format" => "server#seatbelt_login_state", :as => :seatbelt_state
  
  match "/consumer" => "consumer#index", :as => :consumer
  match "/consumer/start" => "consumer#start", :as => :consumer_start
  match "/consumer/complete" => "consumer#complete", :as => :consumer_complete
  
  match "/:account.:format" => "accounts#show", :as => :identity
  match "/:account" => "accounts#show", :as => :formatted_identity
  
  match "/help" => "info#help", :as => :help
  match "/safe-login" => "info#safe_login", :as => :safe_login
  root :to => "info#index", :as => :home
  
end
