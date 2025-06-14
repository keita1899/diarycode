module Authenticatable
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  class_methods do
    def from_omniauth(auth)
      return nil unless auth&.provider && auth.uid

      user = existing_authentication?(auth) ? existing_user(auth) : create_new_user_from_auth(auth)
      if auth.provider == "github"
        user.update!(github_username: auth.info.nickname)
      end
      user
    end

    private

      def existing_authentication?(auth)
        Authentication.exists?(provider: auth.provider, uid: auth.uid)
      end

      def existing_user(auth)
        Authentication.find_by(provider: auth.provider, uid: auth.uid).user
      end

      def create_new_user_from_auth(auth)
        email = auth.info&.email
        return nil if email.blank?

        user = find_by(email: email) || new(email: email, password: Devise.friendly_token[0, 20])
        user.save! unless user.persisted?
        user.authentications.create!(extract_auth_data(auth))
        user
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
