# -*- coding:utf-8 -*-

# OpenID Connect - Relying Party (RP) Sample
# Copyright (c) Hisashi Horikawa.

=begin
`POST catch_response` で次のエラーになる

```
Started POST "/auth/google_implicit/catch_response" for 127.0.0.1 at 2024-06-09 13:20:59 +0900
Processing by Auth::GoogleImplicitController#catch_response as HTML
  Parameters: {"state"=>"7f4c11f1c37145e3358164e62dd659ef96d1925e52f2bc7f7cb687ff7fd6dfbc", "access_token"=>"[FILTERED]", "token_type"=>"[FILTERED]", "expires_in"=>"3599", "scope"=>"email profile https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile openid", "id_token"=>"[FILTERED]", "authuser"=>"0", "prompt"=>"none"}
Can't verify CSRF token authenticity.
Completed 422 Unprocessable Entity in 5ms (ActiveRecord: 0.0ms | Allocations: 483)

ActionController::InvalidAuthenticityToken (ActionController::InvalidAuthenticityToken):
```

解決: `csrf-token` を付けて投げ込むこと。
=end


class Auth::ConnectOpSampleImplicitController < Auth::BaseController
  before_action :setup_swd, only: 'create'
  before_action :set_model_class

  # ログイン処理
  # POST
  def catch_response
    #begin
      id_token, access_token = @model_class.decode_token params, session[:nonce]

      # Rails 6: `render text:` ではなく, `render plain:`
      render plain: "<p>id_token:<br />" + ERB::Util.html_escape(id_token.inspect) +
                    "<p>client_id:<br />" + @model_class.options[:client_id] +
                    "<p>nonce:<br />" + session[:nonce],
             layout: false
      session.delete(:nonce)

      userinfo = access_token.userinfo!
      raise userinfo.inspect
      
      # この後ろがログイン処理
      # TODO: 
    #rescue Exception => err
    #  render plain: 'Critical error: ' + ERB::Util.html_escape(err.inspect)
    #end
  end

  
private
  # for `before_action`
  def setup_swd
    # `http:` を通す。本来は不要
    SWD.url_builder = URI::HTTP
  end
  
  def set_model_class
    @model_class = Auth::ConnectOpSampleImplicit
  end

end # class Auth::GoogleController

