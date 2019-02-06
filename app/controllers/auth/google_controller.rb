# -*- coding:utf-8 -*-

# OpenID Connect - Relying Party (RP) Sample
# Copyright (c) Hisashi Horikawa.

class Auth::GoogleController < Auth::BaseController

  # GET /auth/google/new
  def new
    session[:state] = SecureRandom.hex(32)
    session[:nonce] = SecureRandom.hex(32)
    redirect_to Auth::Google.authorization_uri(
                  response_type: 'id_token token', # Implicit Flow
                  state: session[:state],
                  nonce: session[:nonce], # Implicit Flow では必須            
                )
  end


  # ログイン処理
  def catch_response
    id_token, access_token = Auth::Google.decode_token params, session[:nonce]

    render :text => "<p>" + ERB::Util.html_escape(id_token.inspect) +
                    "<p>" + Auth::Google.options[:client_id] +
                    "<p>" + session[:nonce],
           :layout => false
    session.delete(:nonce)
  end
end # class Auth::GoogleController
