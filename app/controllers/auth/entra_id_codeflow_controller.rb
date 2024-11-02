
# `redirect_uri` を別にしなければならないので、複数の IdP を使うときは、
# クラスを分ける.
# 内容は一緒


class Auth::EntraIdCodeflowController < Auth::CodeflowBaseController
  before_action :set_model_class

  # POST
  # create()

  # GET
  # callback()
  
private
  def set_model_class
    @model_class = Auth::EntraIdCodeflow
  end

end


