class CreateAuthentications < ActiveRecord::Migration[7.1]
  def change
    create_table :authentications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :name
      t.string :email
      t.string :avatar_url
      t.text :access_token

      t.timestamps
    end

    # プロバイダーとUIDの組み合わせは一意
    add_index :authentications, [:provider, :uid], unique: true
    # ユーザーと同じプロバイダーでの重複認証を防ぐ
    add_index :authentications, [:user_id, :provider], unique: true
  end
end
