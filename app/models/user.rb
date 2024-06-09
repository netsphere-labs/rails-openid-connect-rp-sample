
# ユーザ
class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :name, presence:true
  
  # メールで識別.
  validates :email, presence:true
  validates :email, uniqueness: true


  # Sorcery `login()` から callback される.
  def self.authenticate provider_class, code, nonce, verifier
    yield provider_class.authenticate(code, nonce, verifier)
  end
end
