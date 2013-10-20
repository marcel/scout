Scout::Server::Application.routes.draw do
  devise_for :accounts, path_names: {sign_in: 'login', sign_out: 'logout', sign_up: 'kensentme'}
  root to: "player_point_totals#index"

  # get '/cabalist', to: Cabalist::Frontend, :anchor => false, :as => :cabalist
  get "expert_ranks/(:week)", to: "expert_ranks#index", as: :expert_ranks
  get "expert_ranks/show"
  get "watches", to: "watch#index", as: :watch_list
  get "watch/update/:id", to: "watch#update", as: :update_watch

  get "/matchups/(:week)", to: "matchups#index", as: :matchups
  resources :teams do
    member do
      get 'roster/(:week)', to: "rosters#show", as: :roster
    end
    # resource :roster, only: :show
  end

  get 'search', to: "players#search", as: :player_search

  resources :players do
    resource :player_point_totals, as: :points, path: :points, only: :show
  end

  get "/defense/(:week)", to: "player_point_totals#defense", as: :defense
  get "/offense/(:week)", to: "player_point_totals#offense", as: :offense

  get "/targets/(:week)", to: "player_point_totals#targets", as: :targets
  get "/carries/(:week)", to: "player_point_totals#carries", as: :carries
  get "/points/season", to: "player_point_totals#season", as: :season
  get "/points/(:week)", to: "player_point_totals#index", as: :points

  get "/projections/(:week)", to: "projections#index"
  resources :projections

  get "/injuries/(:week)", to: "injuries#index"
  resources :injuries

  resources :accounts

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
