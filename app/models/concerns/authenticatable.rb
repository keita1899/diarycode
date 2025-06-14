module Authenticatable
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  class_methods do
    def from_omniauth(auth)
      return nil unless valid_auth?(auth)

      user = find_or_create_user_from_auth(auth)
      return nil unless user

      update_github_username(user, auth)
      user
    end

    private

      def valid_auth?(auth)
        auth&.provider && auth.uid
      end

      def find_or_create_user_from_auth(auth)
        return existing_user(auth) if existing_authentication?(auth)

        create_new_user_from_auth(auth)
      end

      def update_github_username(user, auth)
        return unless auth.provider == "github"
        return if auth.info&.nickname.blank?

        user.update!(github_username: auth.info.nickname)
      end

      def existing_authentication?(auth)
        Authentication.exists?(provider: auth.provider, uid: auth.uid)
      end

      def existing_user(auth)
        Authentication.find_by(provider: auth.provider, uid: auth.uid).user
      end

      def create_new_user_from_auth(auth)
        email = auth.info&.email
        return nil if email.blank?

        ActiveRecord::Base.transaction do
          user = find_by(email: email) || new(email: email, password: Devise.friendly_token[0, 20])
          user.save! unless user.persisted?
          user.authentications.create!(extract_auth_data(auth))
          user
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error("OAuthユーザー作成に失敗しました: #{e.message}")
          nil
        end
      end

      def extract_auth_data(auth)
        {
          provider: auth.provider, uid: auth.uid, name: auth.info&.name,
          email: auth.info&.email, avatar_url: auth.info&.image, access_token: auth.credentials&.token
        }
      end
  end
  # rubocop:enable Metrics/BlockLength

  def oauth_user?
    authentications.exists?
  end

  def has_github_auth?
    authentications.github.exists?
  end

  def has_x_auth?
    authentications.x.exists?
  end

  def connected_providers
    authentications.pluck(:provider)
  end
end
