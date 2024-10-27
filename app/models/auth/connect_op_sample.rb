
# with PKCE. 非常に簡単.
class Auth::ConnectOpSample < Auth::Base
  self.config_file = "config/auth/connect_op_sample.yml"

  # Sorcery -> user_class -> callback
  def self.authenticate(code, nonce, verifier)
    # token の検証
    client.authorization_code = code

    # `Rack::OAuth2::Client` のメソッド. ここで IdP にアクセス
    # PKCE Verifier が異なる場合、ここで `Rack::OAuth2::Client::Error` 例外:
    #    invalid_grant :: Invalid code verifier.
    token = client.access_token! :secret_in_body, {
                                   code_verifier: verifier}  
    id_token = OpenIDConnect::ResponseObject::IdToken.decode(
      token.id_token, jwks
    )
    # 検証に失敗すると例外
    id_token.verify!({ :issuer => config.issuer,
                         :nonce => nonce,
                         :client_id => options[:client_id] })

    # connect_op_sample は id_token が最小限
    # > id_token.raw_attributes
    #=> {"iss"=>"http://localhost:4000", "sub"=>"41423a1073fed80b", "aud"=>"f714648330c6a5809395f40844c939ea", "exp"=>1729998465, "iat"=>1729998165, "nonce"=>"flVbHRpazGcAdjCrPK0noRUDqgwiNi5ZOCjj0S8Bg0Z"}

    userinfo = token.userinfo!
    raise userinfo.inspect
    email = userinfo[:email]
    user = User.find_by_email(email) || User.new(email:email)
    user.name = userinfo[:name]
    user.image = userinfo[:picture]
    user.save!

    return user
  end
end

