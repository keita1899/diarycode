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

  # OmniAuthでのユーザー作成・認証
  def self.from_omniauth(auth)
    existing_authentication = find_existing_authentication(auth)
    return existing_authentication.user if existing_authentication

    user = find_or_create_user_by_email(auth.info.email)
    create_authentication_for_user(user, auth)
    user
  end

  private_class_method def self.find_existing_authentication(auth)
    Authentication.find_by(provider: auth.provider, uid: auth.uid)
  end

  private_class_method def self.find_or_create_user_by_email(email)
    User.find_by(email: email) || create_user_with_email(email)
  end

  private_class_method def self.create_user_with_email(email)
    User.create!(
      email: email,
      password: Devise.friendly_token[0, 20],
    )
  end

  private_class_method def self.create_authentication_for_user(user, auth)
    user.authentications.create!(
      provider: auth.provider,
      uid: auth.uid,
      name: auth.info.name,
      email: auth.info.email,
      avatar_url: auth.info.image,
      access_token: auth.credentials&.token,
    )
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
