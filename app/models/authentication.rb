class Authentication < ApplicationRecord
  belongs_to :user

  # Access tokenを暗号化して保存
  encrypts :access_token

  validates :provider, :uid, presence: true
  validates :uid, uniqueness: { scope: :provider }
  validates :provider, uniqueness: { scope: :user_id }

  # スコープ
  scope :by_provider, ->(provider) { where(provider: provider) }
  scope :github, -> { by_provider("github") }
  scope :x, -> { by_provider("x") }

  # プロバイダー名をキャメライズして表示用に
  def provider_name
    case provider
    when "github"
      "GitHub"
    when "x"
      "X (Twitter)"
    else
      provider.humanize
    end
  end
end
