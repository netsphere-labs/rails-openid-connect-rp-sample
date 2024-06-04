
# ユーザ
class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :name, presence:true
  
  # メールで識別.
  validates :email, presence:true
  validates :email, uniqueness: true

end
