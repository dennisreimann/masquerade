Masquerade::Application.routes.draw do

  resource :account, :member => { :activate => :get, :password => :get, :change_password => :put } do
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
  
  
  match "/forgot_password", :to => "passwords#new", :as => :forgot_password
  match "/reset_password/:id", :to => "passwords#edit", :as => :reset_password
  
  match "/login", :to => "sessions#new", :as => :login
  match "/logout/:id", :to => "sessions#destroy", :as => :logout
  
  match "/server", :to => "server#index", :as => :server
  match "/server/decide", :to => "server#decide", :as => :decide
  match "/server/proceed", :to => "server#proceed", :as => :proceed
  match "/server/complete", :to => "server#complete", :as => :complete
  match "/server/cancel", :to => "server#cancel", :as => :cancel
  match "/server/seatbelt/config.:format", :to => "server#seatbelt_config", :as => :seatbelt_config
  match "/server/seatbelt/state.:format", :to => "server#seatbelt_login_state", :as => :seatbelt_state
  
  match "/consumer", :to => "consumer#index", :as => :consumer
  match "/consumer/start", :to => "consumer#start", :as => :consumer_start
  match "/consumer/complete", :to => "consumer#complete", :as => :consumer_complete
  
  match "/", :to => "info#index", :as => :home
  match "/help", :to => "info#help", :as => :help
  match "/safe-login", :to => "info#safe_login", :as => :safe_login
  
  match "/:account.:format", :to => "accounts#show", :as => :identity
  match "/:account", :to => "accounts#show", :as => :formatted_identity
  
end
