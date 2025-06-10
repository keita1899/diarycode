class EncryptExistingAccessTokens < ActiveRecord::Migration[7.1]
  def up
    # 既存のaccess_tokenを暗号化
    # 現在のところ、access_tokenは空の状態なので、特に処理は不要
    # 将来的にaccess_tokenが保存されている場合は、以下のような処理が必要
    # 
    # Authentication.where.not(access_token: nil).find_each do |auth|
    #   # 暗号化する前に、一時的にencryptsを無効にして読み込み
    #   unencrypted_token = auth.read_attribute_before_type_cast(:access_token)
    #   # encrypts有効状態で再設定（自動的に暗号化される）
    #   auth.update_column(:access_token, unencrypted_token) if unencrypted_token.present?
    # end
    
    # 現在は何もしない（既存データが存在しないため）
  end

  def down
    # ダウンマイグレーションは復号化のリスクがあるため、
    # セキュリティ上の理由で実装しない
    raise ActiveRecord::IrreversibleMigration, "暗号化されたaccess_tokenは復号化できません"
  end
end
