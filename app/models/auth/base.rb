# -*- coding:utf-8 -*-

class Auth::Base
  include ActiveModel::Model

  class << self
    attr_reader :options

    attr_accessor :config_file
    
    # 設定ファイル + discover! の結果
    # @return [OpenIDConnect::Discovery::Provider::Config::Response] config.
    def config
      return @config if @config

      @options = YAML.load_file(Rails.root.to_s + "/" + config_file)[Rails.env].symbolize_keys
      raise ArgumentError if !options[:client_id]
      raise ArgumentError if !options[:redirect_uri]
      # 重要! Implicit Flow では secret を保存してはならない.
      raise SecurityError if options[:client_secret] 

      @config = OpenIDConnect::Discovery::Provider::Config.discover!(
                       options[:issuer])
      return @config
    end

    
    def client
      config()
      @client ||= OpenIDConnect::Client.new(
        ### Rack::OAuth2::Client
        :identifier   => options[:client_id],  # required
        #:secret       => config[:client_secret],
        #:private_key  
        :redirect_uri => options[:redirect_uri],
        #:scheme
        #:host
        #:port
        :authorization_endpoint => config.authorization_endpoint,
        :token_endpoint         => config.token_endpoint,
        ### OpenIDConnect::Client
        :userinfo_endpoint      => config.userinfo_endpoint,
        #:expires_in
      )
    end

    # @return Authentication Request URL
    def authorization_uri(options = {})
      client.authorization_uri options.merge(
                                 scope: config.scopes_supported)
    end

    # @return [JSON::JWK::Set] IdP の公開鍵の組. JSON Web Key Set (JWKS)
    def idp_public_keys
      keys = config.jwks  # jwks_uri に対する HTTP アクセスが起こる.
      return keys
    end

    def left_half_hash_of string, hash_length
      digest = OpenSSL::Digest.new("SHA#{hash_length}").digest string
      UrlSafeBase64.encode64 digest[0, hash_length / (2 * 8)]
    end

    def decode_token response, nonce
      id_token = OpenIDConnect::ResponseObject::IdToken.decode(
                        response['id_token'],
                        idp_public_keys)
      r = id_token.verify!({
                        :issuer => config.issuer,
                        :nonce => nonce,
                        :client_id => options[:client_id]})
    
      # さらに, access token を検証 (validation) しなければならない.
      jwt = JSON::JWT.decode response['id_token'], :skip_verification
      hash_length = jwt.alg[2, 3].to_i
      if id_token.at_hash !=
                left_half_hash_of(response['access_token'], hash_length)
        raise "invalid access_token!!"
      end

      return id_token, response['access_token']
    end
      
  end # class << self

end
