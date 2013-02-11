SumTimes::Application.routes.draw do

  resources :holidays, :only => [:index]

  resources :schedules, :except => [:update, :edit, :delete]
  resources :lates
  resources :leaves
  resources :profiles, :except => [:edit, :update] do
    collection do
      get 'edit'
      put '' => 'profiles#update'
    end
  end
  resources :timesheets, :only => [:index, :show] do
    member do
      put 'submit'
      put 'accept'
      delete 'reject'
      put 'regenerate'
    end
  end

  namespace :admin do
    resources :holidays, :except => [:show]
    resources :profiles
    resources :supervisors, :only => [:index, :edit, :update, :destroy]
    resources :leave_transactions, :only => [:new, :create]
    resources :timesheets, :only => [:index, :show] do
      collection do
        post 'generate'
      end
    end
    resources :accruals, :only => [:index, :new, :create]
  end

  devise_for :admins
  devise_for :users

  root :to => "schedules#index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
