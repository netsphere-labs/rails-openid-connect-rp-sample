
# OpenID Connect Relying Party (RP) Sample
# Copyright (c) Hisashi Horikawa.


# 編集したら, <kbd>rails routes</kbd> で確認すること.

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest


  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # 単数形リソースであっても，デフォルトコントローラ名は複数形.
  # => `controller:` でクラス名を指定.
  resource :account, only: [:show, :create, :edit, :update],
                     controller: 'account' do
    get 'sign_in'
  end

  # UserSessionsController
  resource :user_session, only: %i[create, destroy]

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  namespace :auth do
    resource :google_codeflow, controller:'google_codeflow', only:[:create] do
      get 'callback'  # redirect back
    end

    # Entra ID (旧 Azure AD)
    resource :entra_id_codeflow, controller:'entra_id_codeflow', only:[:create] do
      get 'callback'  # redirect back
    end

    resource :connect_op_sample, controller:'connect_op_sample', only:[:create] do
      get 'callback'  # redirect back
    end

    
    # The Implicit Flow ############################################
    
    resource :google_implicit, controller:'google_implicit' do
      get 'callback'  # redirect back
      post 'catch_response'
    end

    resource :entra_id_implicit, controller:'entra_id_implicit' do
      get 'callback'  # redirect back
      post 'catch_response'
    end
    
    resource :connect_op_sample_implicit, controller:'connect_op_sample_implicit' do
      get 'callback'  # redirect back
      post 'catch_response'
    end

  end
end

