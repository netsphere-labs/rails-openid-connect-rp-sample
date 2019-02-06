# -*- coding:utf-8 -*-

# See https://postd.cc/jwt-json-web-tokens-is-bad-standard-that-everyone-should-avoid/
#     JOSE（JavaScriptオブジェクトへの署名と暗号化）は、絶対に避けるべき悪い標
#     準規格である

require 'openid_connect'

# 'openid_connect' パッケージは, id_token の検証を行うルーチンがあるが,
# 署名の検証までは行わないように見えた。
# Implicit Flow では、 署名が IdP のものか検証を行わないと, セキュリティ上致命的になる。
# => 動作を確認してみる.

# OpenID Connect Implicit Client Implementer's Guide 1.0
#     ID Tokens MUST be signed using JWS. Clients MUST validate the ID Token
#     per Section 2.2.1.

# 公開鍵の入手
# https://accounts.google.com/.well-known/openid-configuration
#     {
#     "jwks_uri": "https://www.googleapis.com/oauth2/v3/certs",


class TokenValidationTest
  # 置き換えること.
  CLIENT_ID = "xxxxxxxxx"

  OPTIONS = {
    :issuer => "https://auth.login.yahoo.co.jp/yconnect/v2"
    #:issuer => "https://accounts.google.com",
  }

  # @return [OpenIDConnect::Discovery::Provider::Config::Response] config.
  def config
    return @config if @config

    #@config = YAML.load_file(Rails.root.to_s + "/config/auth/google.yml")[Rails.env].symbolize_keys
    #raise ArgumentError if !@config[:client_id]
    #raise ArgumentError if !@config[:redirect_uri]
    #raise SecurityError if @config[:client_secret] 

    @config = OpenIDConnect::Discovery::Provider::Config.discover!(
                        OPTIONS[:issuer])
    return @config
  end

  
  # @return [JSON::JWK::Set] IdP の公開鍵の組. JSON Web Key Set (JWKS)
  def idp_public_keys
    keys = config.jwks  # jwks_uri に対する HTTP アクセスが起こる.
    puts keys
    return keys
  end


  def left_half_hash_of string, hash_length
    digest = OpenSSL::Digest.new("SHA#{hash_length}").digest string
    UrlSafeBase64.encode64 digest[0, hash_length / (2 * 8)]
  end

  
  def do_test response, nonce
    # decode() の内部で, JWSの検証が行われる
    # -> IdToken.decode(jwt_string, key)
    # -> JSON::JOSE.decode(input, key_or_secret = nil, algorithms = nil,
    #                      encryption_methods = nil)
    # -> JWT.decode_compact_serialized(jwt_string, key_or_secret,
    #                           algorithms = nil, encryption_methods = nil)
    # -> JWS.decode_compact_serialized(input, public_key_or_secret,
    #                           algorithms = nil)
    # Exception: JSON::JWT::InvalidFormat
    id_token = OpenIDConnect::ResponseObject::IdToken.decode(
                        response['id_token'],
                        idp_public_keys)
    puts id_token.inspect

    # OpenIDConnect::ResponseObject::IdToken クラスは, verify!(expected) で,
    #   - exp が現在時刻より後ろでなければならない
    #   - iss が expected[:issuer] と一致
    #   - nonce が一致
    #   - aud が expected[:audience] || expected[:client_id] を含む.
    # true で、検証に成功.
    r = id_token.verify!({
                        :issuer => config.issuer,
                        :nonce => nonce,
                        :client_id => CLIENT_ID, })
    puts r

    puts "access_token ==============================================="
    
    # さらに, access token を検証 (validation) しなければならない.
    jwt = JSON::JWT.decode response['id_token'], :skip_verification
    puts jwt.inspect
    puts jwt.alg.inspect #=> "RS256" (String)
    hash_length = jwt.alg.to_s[2, 3].to_i
    if id_token.at_hash !=
                left_half_hash_of(response['access_token'], hash_length)
      puts "invalid access_token!!"
      return
    end
    puts "access_token OK!!"
  end
end # class IdTokenValidationTest


# コピペ
response = {
  "access_token"=>"xxxxxxxxxxxxxxxxx",
  "id_token"=>"xxxxxxxxx",
}
nonce = "xxxx"

TokenValidationTest.new.do_test(response, nonce)
