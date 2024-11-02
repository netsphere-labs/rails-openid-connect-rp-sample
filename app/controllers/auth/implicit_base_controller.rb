# -*- coding:utf-8 -*-

class Auth::ImplicitBaseController < ApplicationController
  # POST /auth/google
  def create
    raise SecurityError if request.request_method != 'POST'
    
    session[:state] = SecureRandom.hex(32)
    session[:nonce] = SecureRandom.hex(32)
    redirect_to @model_class.authorization_uri(
                  response_type: 'id_token token', # Implicit Flow
                  state: session[:state],
                  nonce: session[:nonce], # Implicit Flow では必須            
                ), allow_other_host: true
  end

  # IdP からの redirect back
  def callback
    # Webブラウザ経由, JavaScript でパラメタを分解する
    @provider = controller_name()
    render 'auth/base/callback'
  end
end

