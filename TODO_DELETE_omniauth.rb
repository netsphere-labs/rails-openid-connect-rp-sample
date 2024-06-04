# -*- coding:utf-8 -*-

# See omniauth使っててログインキャンセルした時にトップにリダイレクトさせる
#     https://qiita.com/onigra/items/8bd307f9ae31f27c248a
#     Callback denied with OmniAuth
#     https://stackoverflow.com/questions/10963286/callback-denied-with-omniauth

# OmniAuth2:
#   デフォルト値が :on_failure => OmniAuth::FailureEndpoint となっている.
#   OmniAuth::FailureEndpoint#call() ->
#     development 環境なら例外発生、それ以外では redirect_to_failure().

# development 環境でも, 例外ではなく, `/auth/failure` にリダイレクトさせる.
#OmniAuth.config.on_failure = Proc.new do |env| 
#  OmniAuth::FailureEndpoint.new(env).redirect_to_failure()
#end


# Salesforce
# https://login.salesforce.com/.well-known/openid-configuration
#   => 両対応

# LINE
# https://access.line.me/.well-known/openid-configuration
#   => Code Flow のみ.
# "scopes_supported" 値がなく、どうしたらいい?


Rails.application.config.middleware.use OmniAuth::Builder do
  # 設定の場所:
  # <<issuer>>/.well-known/openid-configuration
  
  # Authentication using the Authorization Code Flow
  # response_type = 'code'
  provider 'openid_connect', {
        # Google Identity Platform
        name: 'google_codeflow',
             
        # https://accounts.google.com/.well-known/openid-configuration
        issuer: 'https://accounts.google.com', 
         
        # 'openid' で OpenID Connect 
        # サポート範囲は "scopes_supported" 値.
        scope: [:openid, :email, :profile], 

        # "response_types_supported" 値.
        # 'code' is Basic flow. 'token id_token' is Implicit flow. 
        response_type: :code, 
 
        discovery: true,  
 
        client_options: { 
          #scheme: "https", 
          #host: "accounts.google.com", 
          #port: 443,  
 
          # Google API Console での指定と厳密に一致していること. 
          # https://console.cloud.google.com/apis/credentials 
          identifier: ENV['GOOGLE_CLIENT_ID'], 
          secret: ENV['GOOGLE_CLIENT_SECRET'], 
          redirect_uri: (ENV['MYSAMPLE_HOST'] || '') + '/auth/google_codeflow/callback',
        }, 
  }

  #Rails.application.credentials.google[:client_id],
  #Rails.application.credentials.google[:client_secret]

  provider 'openid_connect', { 
        name: 'yahoojp_codeflow', 
        issuer: 'https://auth.login.yahoo.co.jp/yconnect/v2', 
         
        scope: [:openid, :email, :profile, :address], 
         
        response_type: 'code', 
 
        discovery: true,  
 
        client_options: { 
          #scheme: "https", 
          #host: "auth.login.yahoo.co.jp", 
          #port: 443, 
 
          identifier: (ENV['YAHOOJP_CLIENT_ID'] || raise), 
          secret: ENV['YAHOOJP_CLIENT_SECRET'], 
          redirect_uri: (ENV['MYSAMPLE_HOST'] || '') + '/auth/yahoojp_codeflow/callback',
        }, 
  }

  provider 'openid_connect', {
        # Azure Active Directory V2
        name: 'azure_ad_codeflow',

        # テナントID が含まれる.     
        # "https://login.microsoftonline.com/{tenantid}/v2.0"
        # https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration
        issuer: ENV['AZURE_ISSUER'], 
         
        scope: [:openid, :profile, :email, :offline_access], 
         
        # ドキュメントでは, Azure ADは, 'id_token' を含めなければならないことになっている; 
        # https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-protocols-openid-connect-code 
        # 実際には, ['code', 'id_token'] はレスポンスが不正. フラグメントになる. 
        # ['code', 'id_token', 'token'] では unsupported_response_type 
        # => 結局, 'code' のみでよい. 
        response_type: 'code', 
 
        # Azure ADのみ.
        # この key は廃止.
        #send_client_secret_to_token_endpoint: true, 
         
        discovery: true,  
 
        client_options: { 
          #scheme: "https", 
          #host: "login.microsoftonline.com", # v2: issuer と同じになった.
          #port: 443,  
 
          identifier: ENV['AZURE_CLIENT_ID'], 
          secret: ENV['AZURE_CLIENT_SECRET'], 
          redirect_uri: (ENV['MYSAMPLE_HOST'] || '') + '/auth/azure_ad_codeflow/callback',
        }, 
  }

  provider 'openid_connect', {
        name: 'nov_op_sample',
        issuer: 'http://localhost:4000',
         
        scope: [:openid, :profile, :email, :address, :phone], 
        response_type: 'code', 
 
        discovery: true,  
 
        client_options: { 
          #scheme: "https", 
          #host: "login.microsoftonline.com", # v2: issuer と同じになった.
          #port: 443,  
 
          identifier: ENV['NOV_OP_SAMPLE_CLIENT_ID'], 
          secret: ENV['NOV_OP_SAMPLE_SECRET'], 
          redirect_uri: (ENV['MYSAMPLE_HOST'] || '') + '/auth/nov_op_sample/callback',
        }, 
  }



  ############################################################################
  # Authentication using the Implicit Flow
  # response_type = 'id_token token'

  provider 'openid_connect', {
        name: 'google_implicit',
        issuer: 'https://accounts.google.com', 
         
        # 'openid' で OpenID Connect 
        # サポート範囲は <issuer>/.well-known/openid-configuration 
        scope: [:openid, :email, :profile], 
         
        # 'code' is Basic flow. 'token id_token' is Implicit flow. 
        response_type: 'id_token',
 
        discovery: true,  
 
        client_options: { 
          #scheme: "https", 
          #host: "accounts.google.com", 
          #port: 443,  
 
          # Google API Console での指定と厳密に一致していること. 
          # https://console.cloud.google.com/apis/credentials 
          identifier: ENV['GOOGLE_CLIENT_ID'],
          # Secret を保存してはならない (MUST NOT)
          #secret: ENV['GOOGLE_CLIENT_SECRET'], 
          redirect_uri: (ENV['MYSAMPLE_HOST'] || '') + '/auth/google_implicit/implicit_back', # callback でないことに注意!
        }, 
  }

  # 鍵を失うと復元できなくなる.
  # config/master.key -> config/credentials.yml.enc
  # config/credentials/development.key
  #     -> config/credentials/development.yml.enc
  # => development 環境ではやりすぎじゃなイカ?

  #Rails.application.credentials.google[:client_id],
  #Rails.application.credentials.google[:client_secret]

  provider 'openid_connect', { 
        name: 'yahoojp_implicit', 
        issuer: 'https://auth.login.yahoo.co.jp/yconnect/v2', 
         
        scope: [:openid, :email, :profile, :address], 
         
        response_type: 'id_token',
 
        discovery: true,  
 
        client_options: { 
          #scheme: "https", 
          #host: "auth.login.yahoo.co.jp", 
          #port: 443,  
 
          identifier: ENV['YAHOOJP_CLIENT_ID'], 
          # Secret を保存してはならない (MUST NOT)
          #secret: ENV['YAHOOJP_CLIENT_SECRET'], 
          redirect_uri: (ENV['MYSAMPLE_HOST'] || '') + '/auth/yahoojp_implicit/implicit_back'  
        }, 
  }

  provider 'openid_connect', { 
        name: 'azure_ad_implicit', 
        issuer: ENV['AZURE_ISSUER'], 
         
        scope: [:openid, :profile, :email, :offline_access], 
        response_type: 'id_token',
 
        # Azure ADのみ.
        # この key は廃止.
        #send_client_secret_to_token_endpoint: true, 
         
        discovery: true,  
 
        client_options: { 
          #scheme: "https", 
          #host: "login.microsoftonline.com", # v2: issuer と同じになった.
          #port: 443,  
 
          identifier: ENV['AZURE_CLIENT_ID'], 
          # Secret を保存してはならない (MUST NOT)
          #secret: ENV['AZURE_CLIENT_SECRET'], 
          redirect_uri: ENV['AZURE_IMPLICIT_REDIRECT_URI'], 
        }, 
  }

  provider 'openid_connect', { 
        name: 'nov_op_sample_implicit', 
        issuer: 'http://localhost:4000',

        scope: [:openid, :profile, :email, :offline_access], 
        response_type: 'id_token',
 
        discovery: true,  
 
        client_options: { 
          #scheme: "https", 
          #host: "login.microsoftonline.com", # v2: issuer と同じになった.
          #port: 443,  
 
          identifier: ENV['NOV_OP_SAMPLE_CLIENT_ID'],
          # Secret を保存してはならない (MUST NOT)
          #secret: ENV['AZURE_CLIENT_SECRET'], 
          redirect_uri: (ENV['MYSAMPLE_HOST'] || '') + '/auth/nov_op_sample_implicit/implicit_back', 
        }, 
  }
  
end


