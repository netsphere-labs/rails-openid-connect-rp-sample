
# `redirect_uri` を別にしなければならないので、複数の IdP を使うときは、
# クラスを分ける.
# 内容は一緒


class Auth::CodeflowBaseController < ApplicationController
  
  # POST /auth/google
  def create
    raise SecurityError.new if request.request_method != 'POST'

    # 256bit を作ろうとすると, hex(32), 出力は 64文字
    #                          alphanumeric(43), 出力は43文字
    session[:state] = SecureRandom.alphanumeric(43) 
    session[:nonce] = SecureRandom.alphanumeric(43)

    # 長さ: 43..128 文字. 使用可能文字: A-Z a-z 0-9 "-" / "." / "_" / "~"
    # See RFC 7636 4.1.
    session[:code_verifier] = SecureRandom.alphanumeric(43)
    
    redirect_to @model_class.authorization_uri(
                    response_type: 'code', # Authorization Code Flow
                    scope: ['openid', "email", "profile"], # 'openid' 必須
                    state: session[:state], # 推奨. FAPI: `scope` に `openid` を含めないときは必須.
                    nonce: session[:nonce], # FAPI: `scope` に `openid` を含めるときは必須.
                    code_challenge: make_challenge(session[:code_verifier] ),
                    code_challenge_method:"S256"  # 必ずこっち
                )
  end

  
  # IdP からの callback
  def callback
    if params[:code].blank? || session[:state] != params[:state]
      raise AuthenticationRequired.new
    end
    session.delete(:state)
    
    # `login()` 内部で `user_class.authenticate(*credentials)` が呼び出される
    nonce = session[:nonce];            session.delete(:nonce)
    verifier = session[:code_verifier]; session.delete :code_verifier
    if login(@model_class, params[:code], nonce, verifier) 
      redirect_back_or_to('/account', notice: 'Login successful')
    else
      flash[:alert] = 'Login failed'
      redirect_to '/'
    end
    
  end

  
private
  # code_challenge = BASE64URL-ENCODE(SHA256(ASCII(code_verifier)))
  def make_challenge verifier
    require 'base64'
    require 'digest'

    Base64.urlsafe_encode64(Digest::SHA256.digest(verifier),
                              padding:false)
  end

end
