Masquerade::Application.routes.draw do

  resource :account do
    get :activate
    get :password
    put :change_password
    
    resources :personas
    resources :sites
    resource :yubikey_association, :only => [:create, :destroy]
  end

  resource :password
  resource :session, :only => [:new, :create, :destroy]
  
  get "/help" => "info#help", :as => :help
  get "/safe-login" => "info#safe_login", :as => :safe_login
  
  get "/forgot_password" => "passwords#new", :as => :forgot_password
  get "/reset_password/:id" => "passwords#edit", :as => :reset_password

  get "/login" => "sessions#new", :as => :login
  get "/logout" => "sessions#destroy", :as => :logout
  post '/resend_activation_email/*account' => 'accounts#resend_activation_email', :as => :resend_activation_email

  match "/server" => "server#index", :as => :server
  match "/server/decide" => "server#decide", :as => :decide
  match "/server/proceed" => "server#proceed", :as => :proceed
  match "/server/complete" => "server#complete", :as => :complete
  match "/server/cancel" => "server#cancel", :as => :cancel
  get "/server/seatbelt/config.:format" => "server#seatbelt_config", :as => :seatbelt_config
  get "/server/seatbelt/state.:format" => "server#seatbelt_login_state", :as => :seatbelt_state

  get "/consumer" => "consumer#index", :as => :consumer
  post "/consumer/start" => "consumer#start", :as => :consumer_start
  match "/consumer/complete" => "consumer#complete", :as => :consumer_complete

  get "/*account" => "accounts#show", :as => :identity

  root :to => "info#index"

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

end
