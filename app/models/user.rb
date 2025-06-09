class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :reports, dependent: :destroy
  has_many :templates, dependent: :destroy

  # カスタムパスワードバリデーション
  validate :password_complexity, if: :password_required?

  private

    def password_required?
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
