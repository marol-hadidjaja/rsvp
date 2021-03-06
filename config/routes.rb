Rails.application.routes.draw do
  devise_for :users, :controllers => { :sessions => "sessions" }
  # resources :users
  get 'invitees/relations' => 'invitees#relations'
  resources :events, shallow: true do
    get 'receptionist' => 'events#receptionist'
    get 'receptionist/new' => 'events#receptionist_new'
    post 'receptionist' => 'events#receptionist_create', as: 'receptionist_create'
    #get 'receptionist/edit' => 'events#receptionist_edit'
    #patch 'receptionist' => 'events#receptionist_update', as: 'receptionist_update'
    resources :invitees, shallow: true do
      member do
        post 'update_response'
        get 'update_arrival' => 'invitees#update_arrival_form'
        post 'update_arrival'
        get 'invitees/resend_invitation' => 'invitees#resend_invitation'
      end
    end
    get 'invitees/import' => 'invitees#import_form'
    post 'invitees/import' => 'invitees#import'
    get 'invitees/export' => 'invitees#export'
    get 'invitees/invitation' => 'invitees#invitation'
    # get 'invitees/resend_invitation' => 'invitees#resend_invitation'
  end
  get 'images/:id/:style' => 'events#images'
  get 'invitation/:id/:style' => 'events#invitation'

  get 'oauth2callback' => 'events#oauth2callback'
  get 'authorize' => 'events#authorize'
  # get 'googlecalendar' => 'invitees#calendars'

  root 'events#index'
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
