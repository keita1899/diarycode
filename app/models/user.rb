class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:github]

  has_many :reports, dependent: :destroy
  has_many :templates, dependent: :destroy
  has_many :authentications, dependent: :destroy
  belongs_to :default_template, class_name: "Template", optional: true

  # カスタムパスワードバリデーション
  validate :password_complexity, if: :password_required?

  # OmniAuthでのユーザー作成・認証（新しいロジック）
  def self.from_omniauth(auth)
    # 既存の認証情報を検索
    authentication = Authentication.find_by(provider: auth.provider, uid: auth.uid)

    if authentication
      # 既存の認証情報が見つかった場合、そのユーザーを返す
      authentication.user
    else
      # 同じメールアドレスのユーザーを検索
      user = User.find_by(email: auth.info.email)

      # ユーザーが存在しない場合は新規作成
      if user.nil?
        user = User.create!(
          email: auth.info.email,
          password: Devise.friendly_token[0, 20],
        )
      end

      # 新しい認証情報を作成
      user.authentications.create!(
        provider: auth.provider,
        uid: auth.uid,
        name: auth.info.name,
        email: auth.info.email,
        avatar_url: auth.info.image,
        access_token: auth.credentials&.token,
      )

      user
    end
  end

  # デフォルトテンプレートの設定メソッド
  def assign_default_template(template)
    if templates.include?(template)
      update!(default_template: template)
    end
  end

  # デフォルトテンプレートをクリア
  def clear_default_template
    update!(default_template: nil)
  end

  # SNS認証ユーザーかどうかを判定
  def oauth_user?
    authentications.exists?
  end

  # GitHub認証を持っているかチェック
  def has_github_auth?
    authentications.github.exists?
  end

  # X認証を持っているかチェック
  def has_x_auth?
    authentications.x.exists?
  end

  # プロバイダー一覧を取得
  def connected_providers
    authentications.pluck(:provider)
  end

  private

    def password_required?
      # OAuth認証ユーザーはパスワード不要
      return false if oauth_user?

      !persisted? || !password.nil? || !password_confirmation.nil?
    end

    def password_complexity
      return if password.blank?

      # 少なくとも1つの文字を含む必要がある
      unless password.match?(/[a-zA-Z]/)
        errors.add(:password, "には少なくとも1つの文字を含む必要があります")
      end

      # 少なくとも1つの数字を含む必要がある
      unless password.match?(/\d/)
        errors.add(:password, "には少なくとも1つの数字を含む必要があります")
      end
    end
end
