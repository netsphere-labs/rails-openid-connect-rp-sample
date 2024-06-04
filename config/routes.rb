
# OpenID Connect Relying Party (RP) Sample
# Copyright (c) Hisashi Horikawa.


# 編集したら, <kbd>rails routes</kbd> で確認すること.

Rails.application.routes.draw do
  # For details on the DSL available within this file, 
  # see https://guides.rubyonrails.org/routing.html

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

