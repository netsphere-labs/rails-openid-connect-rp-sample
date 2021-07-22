# -*- coding:utf-8 -*-

# OpenID Connect - Relying Party (RP) Sample
# Copyright (c) Hisashi Horikawa.

class Auth::GoogleController < Auth::BaseController

  # POST /auth/google
  def create
    raise SecurityError if request.request_method != 'POST'
    
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
    begin
      id_token, access_token = Auth::Google.decode_token params, session[:nonce]

      # Rails 6: render text: ではなく, render plain:
      render plain: "<p>" + ERB::Util.html_escape(id_token.inspect) +
                    "<p>" + Auth::Google.options[:client_id] +
                    "<p>" + session[:nonce],
             layout: false
      session.delete(:nonce)
    rescue Exception => err
      render plain: 'Critical error: ' + ERB::Util.html_escape(err.inspect)
    end
  end
end # class Auth::GoogleController
