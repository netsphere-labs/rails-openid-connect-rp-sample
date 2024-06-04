# -*- coding:utf-8 -*-

# 単数形
#   $ rails g controller session

# Sorcery: この名前がデフォルト.
class UserSessionsController < ApplicationController
  before_action :require_login, only: [:destroy]

  # omniauth callback
  def create
    # automatic user provisioning
    if login(auth_hash)
      session[:idp] = auth_hash.provider
      redirect_to '/account', notice: 'ログインしました!!'
    else
      raise "internal error"
    end
  end

  # The Implicit Flow: redirect back from the provider.
  def implicit_back
    @provider = params[:provider]
  end
  
  # DELETE /session
  def destroy
    idp = session[:idp]
    logout()
    
    # Azure 以外の場合は, ここで完了.
    if idp == "azure_ad_codeflow"
      redirect_to "/auth/azure_ad_codeflow/logout" # Single Logout (SLO)
      return
    end

    redirect_to '/', notice: 'ログアウトしました〜'
  end

private
  def auth_hash
    request.env['omniauth.auth']
  end
end
