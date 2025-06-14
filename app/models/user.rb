class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:github]

  has_many :reports, dependent: :destroy
  has_many :templates, dependent: :destroy
  has_many :authentications, dependent: :destroy
  belongs_to :default_template, class_name: "Template", optional: true

  include Authenticatable
  include TemplateManagement

  # カスタムパスワードバリデーション
  validate :password_complexity, if: :password_required?

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
