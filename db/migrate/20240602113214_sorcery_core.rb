

class SorceryCore < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      # ユーザID
      t.string :email,            null: false, index: { unique: true }

      # パスワードは使わない
      #t.string :crypted_password
      #t.string :salt

      t.string :name,  null:false
      t.string :image

      t.timestamps                null: false
    end
  end
end
