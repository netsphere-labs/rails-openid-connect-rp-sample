
# [historical] OpenID Connect - Implicit Flow Relying Party (RP) sample

Implicit Flow による RP のサンプル。See https://www.nslabs.jp/digital-identity.rhtml

[OpenID Connect Implicit Client Implementer's Guide 1.0](https://openid.net/specs/openid-connect-implicit-1_0.html) を実装。

[historical]
OpenID Connect 認証仕様の基礎である OAuth 2.0 認可 (認証にあらず) フレームワークについて、改定作業が行われている. [The OAuth 2.1 Authorization Framework Internet-Draft](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-10). Implicit Flow は単に削除される見込み。`response_type` = `id_token token` は廃止。
今後は Authorization Code Flow with PKCE を使え。


## インストール

* Requirements

  - Ruby 3.0
  - Ruby on Rails v6.1 
  - openid_connect

This sample application does not use omniauth-openid-connect.

  OpenID Connect Provider (OP) は Google と Yahoo JP.


* Configuration
  `config/auth/google.yml.sample` と `config/auth/yahoojp.yml.sample` ファイルをコピー
  し, 適宜、編集してください。

  client_id を設定してください。
  Implicit Flow では client_secret を保存してはなりません。
  
* How to run the test suite

```bash
    $ rails webpacker:compile
    $ passenger start
```

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

