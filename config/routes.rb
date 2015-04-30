ActionController::Routing::Routes.draw do |map|
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  map.resources :users, :member => { :suspend => :put, :unsuspend => :put, :purge => :delete }
  map.resource :session

  map.open_id_complete 'session', :controller => 'sessions', :action => 'create', :requirements => {:method => 'get'}
  map.root :controller => 'sessions'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  map.connect 'cmt/show.:format', :controller => 'lun/comments', :action => 'show'
  map.connect 'cmt/user/:id', :controller => 'lun/comments', :action => 'user'
  map.connect 'cmt/top.:format', :controller => 'lun/comments', :action => 'top'
  map.connect 'cmt/latest.:format', :controller => 'lun/comments', :action => 'latest'
  map.connect 'cmt/count.:format', :controller => 'lun/comments', :action => 'count'
  map.connect 'cmt/new.:format', :controller => 'lun/comments', :action => 'new'
  map.connect 'cmt/create.:format', :controller => 'lun/comments', :action => 'create'
  map.connect 'cmt/reply.:format', :controller => 'lun/comments', :action => 'reply'
  map.connect 'cmt/spam.:format', :controller => 'lun/comments', :action => 'spam'
  map.connect 'stats', :controller => 'lun/comments', :action => 'index'
  map.connect 'lnk/show.:format', :controller => 'lun/links', :action => 'show'
  map.connect 'lnk/stats.:format', :controller => 'lun/links', :action => 'stats'

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

end
