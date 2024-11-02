
# An OpenID Connect Relying Party (RP) sample

OpenID Connect Provider (OP or IdP) 開発とデバッグのために、いろいろな投げつけをするサンプル。

See https://www.nslabs.jp/identity-samples.rhtml

OmniAuth を使っていたのを止め、実装しなおした。



## Features

OpenID Connect Provider (OP) は Google と Yahoo JP, それに [Rails OpenID Connect IdP AS](https://github.com/netsphere-labs/rails-openid-connect-idp-as/)

このサンプルは, Just-in-time User Provisioning (JIT Provisioning) の例にもなっている。あらかじめユーザ登録されていなくても、シングルサインオンで回ってくるユーザ情報で自サイトにも登録する。


(1) Authorization Code Flow with PKCE によるログイン

 - ✅ Google 実装すみ
 - ✅ Entra ID (旧 Azure AD) 実装すみ
 - Rails OpenID Connect IdP AS  実装すみ
 - <s>Yahoo! JAPAN</s> PPID しか返さず、認証 (本人確認) 目的には使いがたい


生の OAuth 2.0 の Implicit Flow を「認証」に使おうとすると、すごく巨大な穴が空く。OpenID Connect の Implicit Flow はその穴を塞いでいるので問題ない。しかし、巷の解説では混同しているものが非常に多い。

2024 年6月現在, OAuth 2.1 に向けた改訂作業が進んでいる。文言もだいぶ落ち着いてきて、もうすぐ最終化か? [The OAuth 2.1 Authorization Framework Internet-Draft](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-11)
OAuth 2.1 は, 穴を塞ぐのではなく, 単に Implicit Flow を廃止にした。

今後は "public clients" も Authorization Code Flow でカバーしなければならず、Mobile & Desktop Apps では, `nonce` 必須, PKCE 必須。



(2) Implicit Flow によるログイン

[OpenID Connect Implicit Client Implementer's Guide 1.0](https://openid.net/specs/openid-connect-implicit-1_0.html) を実装。

 - ✅ Google 実装すみ
 - ✅ Entra ID (旧 Azure AD) 実装すみ. 管理画面で Implicit Flow を有効にしている場合のみ (デフォルト無効)。

`omniauth_openid_connect` v0.4.0 は, <code>response_type=id_token</code> しかサポートしていない。これはアクセストークンが得られず、妥当ではない。

仕様では, IdP は, アクセストークンを発行しない場合に限って <code>id_token</code> レスポンスにユーザ情報を含めることになっている (Core 1.0: section 5.4) が、Yahoo! JAPAN ID 連携はこの仕様に適合せずユーザ情報を含めないので、動作しない。

ポータビリティのため, クライアントから `id_token token` を投げたうえで, UserInfo エンドポイントからユーザ情報を取得する。



(3) OpenID Connect RP-Initiated Logout 1.0 によるシングルログアウト (SLO)

IdP が <code>end_session_endpoint</code> をサポートしている場合、利用可能。
Azure AD v2 は、主に企業ユースで、シングルログアウトを必要とするユースケースがあるので、サポートしている。

シングルログアウトは, OpenID Connect (や他の OAuth2 上に作られたプロファイル) を使ったユースケースでは, 必要にならないことが多い。各サービス (Relying Party 側) がログアウトするときに Google とかもログアウトしたら、逆に困る。




## How to run

* Requirements

  - Ruby  >= 3.0
  - Ruby on Rails v6.1 
  - openid_connect

このサンプルでは認証フレームワークは Sorcery を使っているが、何でも構わない. 
OmniAuth はメジャーだが、屋上屋になるため、omniauth-openid-connect は使用しない。


* Configuration

1) `config/database.yml.sample` を `database.yml` にコピーし, 適宜修正.

<pre>
  $ <kbd>rake db:migrate</kbd>
</pre>


2) `config/auth/google.yml.sample` と `config/auth/yahoojp.yml.sample` ファイルをコピーし, 適宜、編集してください。

  `client_id` を設定してください。
  Implicit Flow では `client_secret` を保存してはなりません。
  


3) 実行!

Redirect URI は次のとおり;
 - `http://localhost:3030/auth/google_codeflow/callback`
 - `http://localhost:3030/auth/google_implicit/callback`
 
http://localhost:3030/auth/connect_op_sample/callback



## Implicit Flow 実装上の注意

Authorization Code Flow は, クライアントが client secret を安全に保持できない状況では、使ってはならなかった。
Implicit Flow は, このような状況でも使えるように, client secret を必要としない (保存してはならない)。

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
 - Ruby on Rails による実装.
 - OP (IdP) は Azure AD.
 - アクセストークンの検証が必要だが、そもそも取得していない?


[Rails+omniauth-google-oauth2でGoogleログイン(devise無し)](https://zenn.dev/batacon/articles/e9b4a88ede2889)
 - omniauth-google-oauth2 のような IdP ごとに別パッケージを使うのではなく, OpenID Connect で統一的にシングルサインオンしたほうが、穴を作らない、と言う意味でもいい。
 - Devise を使わないのはいいが、この例は, 自作のログインコード、ログアウトコードが雑すぎて、これを参考にするのはむしろ有害。こういう雑なサンプルは、止めてほしい。


