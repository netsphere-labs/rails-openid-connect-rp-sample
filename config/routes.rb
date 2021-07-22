
# OpenID Connect - Relying Party (RP) Sample
# Copyright (c) Hisashi Horikawa.

Rails.application.routes.draw do
  # For details on the DSL available within this file, 
  # see https://guides.rubyonrails.org/routing.html

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  namespace :auth do
    resource :google do
      get 'callback'  # redirect back
      post 'catch_response'
    end

    resource :yahoojp do
      get 'callback'  # redirect back
      post 'catch_response'
    end
  end
end

