# -*- coding:utf-8 -*-

# OpenID Connect - Relying Party (RP) Sample
# Copyright (c) Hisashi Horikawa.


class Auth::EntraIdImplicitController < Auth::ImplicitBaseController
  before_action :set_model_class
 

  # ログイン処理
  # POST
  def catch_response
    begin
      id_token, access_token = @model_class.decode_token params, session[:nonce]

      # Rails 6: `render text:` ではなく, `render plain:`
      render plain: "<p>id_token:<br />" + ERB::Util.html_escape(id_token.inspect) +
                    "<p>client_id:<br />" + @model_class.options[:client_id] +
                    "<p>nonce:<br />" + session[:nonce],
             layout: false
      session.delete(:nonce)

      # この後ろがログイン処理
      # TODO:
    rescue NoMethodError, NameError 
      #render plain: err.inspect
      raise
    rescue Exception => err
      render plain: 'Critical error: ' + ERB::Util.html_escape(err.inspect)
    end
  end

  
private
  def set_model_class
    @model_class = Auth::EntraIdImplicit
  end

end # class Auth::GoogleController

