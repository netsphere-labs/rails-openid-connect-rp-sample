# -*- coding:utf-8 -*-

class Auth::BaseController < ApplicationController
  # redirect back
  def callback
    # Webブラウザ経由, JavaScript でパラメタを分解する
    @provider = controller_name()
    render 'auth/base/callback'
  end
end

