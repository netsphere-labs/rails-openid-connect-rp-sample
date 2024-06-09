
# with PKCE. 非常に簡単.
class Auth::GoogleCodeflow < Auth::Base
  self.config_file = "config/auth/google_codeflow.yml"

  # Sorcery -> user_class -> callback
  def self.authenticate(code, nonce, verifier)
    # token の検証
    client.authorization_code = code

    # `Rack::OAuth2::Client` のメソッド. ここで IdP にアクセス
    token = client.access_token! :secret_in_body, {
                                   code_verifier: verifier}  
    id_token = OpenIDConnect::ResponseObject::IdToken.decode(
      token.id_token, jwks
    )
    # 検証に失敗すると例外
    id_token.verify!({ :issuer => config.issuer,
                         :nonce => nonce,
                         :client_id => options[:client_id] })

    ### id_token が得られた. ここからユーザ登録
    
    email = id_token.raw_attributes[:email]
    user = User.find_by_email(email) || User.new(email:email)
    user.name = id_token.raw_attributes[:name]
    user.image = id_token.raw_attributes[:picture]
    user.save!

    return user
  end
end

