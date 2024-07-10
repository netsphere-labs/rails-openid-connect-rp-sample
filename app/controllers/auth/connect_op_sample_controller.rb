
=begin
`scope` の取扱いについて:

`scope` value   claims
-------------   --------------------------------------------------
`profile`       name, family_name, given_name, middle_name, nickname, preferred_username, profile, picture, website, gender, birthdate, zoneinfo, locale, and updated_at.
`email`         email, email_verified
`address`       address
`phone`         phone_number, phone_number_verified               

スコープはユーザに認可を求める内容を表していて、返却されるのはクレームの値。
Scope "profile, email, address and phone" で求めたクレームの値は、
UserInfo エンドポイントから返却される。Access token が発行されないフローの場合に限って ID Token に含められる。(Core 1.0: section 5.4)

IdP 実装は、往復を減らすために, id_token レスポンスにユーザ情報を含めるものが多い。
=end

class Auth::ConnectOpSampleController < Auth::CodeflowBaseController
  before_action :setup_swd, only: 'create'
  before_action :set_model_class

  # POST
  # create()

  # GET
  # callback()

private
  # for `before_action`
  def setup_swd
    # `http:` を通す。本来は不要
    SWD.url_builder = URI::HTTP
  end

  def set_model_class
    @model_class = Auth::ConnectOpSample
  end
  
end


