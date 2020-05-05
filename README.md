
# OpenID Connect - Relying Party (RP) sample

Implicit Flow による RP のサンプル。

[OpenID Connect Implicit Client Implementer's Guide 1.0](https://openid.net/specs/openid-connect-implicit-1_0.html) を実装。



## インストール

* Requirements

  - Ruby on Rails v4.2
  - openid_connect

This sample application does not use omniauth-openid-connect.

  OpenID Connect Provider (OP) は Google と Yahoo JP.


* Configuration
  `config/auth/google.yml` と `config/auth/yahoojp.yml` ファイルを適宜、編集してください。

  client_id を設定してください。
  Implicit Flow では client_secret を保存してはなりません。
  
* How to run the test suite

    $ passenger start
`localhost:4000` で起動します。



## 実装上の注意

Basic (Authorization Code) Flow は, client secret を安全に保持できない状況では、使ってはならない。
Implicit Flow は, このような状況でも使えるように, client secret を必要としない。(保存してはならない.)

`"response_type"` value は, `id_token token` とする。`id_token` は, Self-Issued OpenID Provider でのみ使われる。

Implicit Flow では, RP から OP に対する直接の問い合わせとレスポンスではなく, Webブラウザを介して id token と access token を得る。そのため、これらのトークンが正当なものか、必ず、検証しなければならない。

次のようなコードになる;

```ruby
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
```



## 先行例

[OpenID Foundationのガイドラインに沿ったRailsでのOIDC Implicit Flow実装](https://selmertsx.hatenablog.com/entry/2018/08/22/104510)

  * Ruby on Rails による実装.
  * OP は Azure AD.
  * アクセストークンの検証が必要だが、そもそも取得していない?

