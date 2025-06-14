class GithubApp
  include ActiveModel::Model
  require "jwt"
  require "octokit"

  attr_accessor :app_id, :private_key_path

  def initialize(attributes = {})
    @app_id = attributes[:app_id] || ENV["GITHUB_APP_ID"]
    @private_key_path = attributes[:private_key_path] || ENV["GITHUB_APP_PRIVATE_KEY_PATH"]
  end

  def check_installation(repo_path)
    Rails.logger.info "Checking installation for #{repo_path}"
    return { installed: false, error: "GitHubリポジトリが設定されていません" } if repo_path.blank?

    begin
      app_client = create_app_client
      installation = app_client.find_repository_installation(repo_path)

      Rails.logger.info "Found installation #{installation.id} for repository #{repo_path}"
      { installed: true, installation_id: installation.id }
    rescue Octokit::NotFound => e
      Rails.logger.warn "Repository installation not found for #{repo_path}: #{e.message}"
      { installed: false, error: "入力されたURLのリポジトリが見つかりません。リポジトリを設定する、もしくは正しいリポジトリのURLを入力してください" }
    rescue => e
      Rails.logger.error "GitHub App installation check failed: #{e.message}"
      { installed: false, error: "GitHub App installation check failed: #{e.message}" }
    end
  end

  def create_installation_access_token(installation_id)
    app_client = create_app_client
    app_client.create_app_installation_access_token(installation_id)[:token]
  end

  def installation_url
    return nil unless @app_id

    "https://github.com/apps/diarycode-app/installations/new"
  end

  private

    def create_app_client
      private_key = OpenSSL::PKey::RSA.new(File.read(@private_key_path))
      payload = {
        iat: Time.now.to_i,
        exp: Time.now.to_i + (10 * 60),
        iss: @app_id,
      }
      jwt = JWT.encode(payload, private_key, "RS256")
      Octokit::Client.new(bearer_token: jwt)
    end
end
