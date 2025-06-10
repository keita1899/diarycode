class EncryptExistingAccessTokens < ActiveRecord::Migration[7.1]
  def up
    # 既存のaccess_tokenデータが存在する場合は暗号化処理が必要
    # 現在は新規実装のため処理不要
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 
          "セキュリティ上の理由により暗号化されたaccess_tokenは復号化できません"
  end
end
