class GithubFile
  include ActiveModel::Model
  require "octokit"
  require "base64"

  attr_accessor :repo_path, :file_path, :content, :commit_message, :access_token

  def initialize(attributes = {})
    @repo_path = attributes[:repo_path]
    @file_path = attributes[:file_path]
    @content = attributes[:content]
    @commit_message = attributes[:commit_message]
    @access_token = attributes[:access_token]
  end

  def push
    return { success: false, error: "必要な情報が不足しています" } unless valid_for_push?

    client = Octokit::Client.new(access_token: @access_token)

    begin
      handle_file_push(client)
    rescue Octokit::NotFound
      create_new_file(client)
    rescue => e
      handle_push_error(e)
    end
  end

  private

    def handle_file_push(client)
      existing_file = client.contents(@repo_path, path: @file_path)
      existing_content = Base64.decode64(existing_file[:content])

      return skip_unchanged_content(existing_file) if content_unchanged?(existing_content)

      result = client.update_contents(@repo_path, @file_path, @commit_message, existing_file[:sha], @content)
      format_success_result(result)
    end

    def create_new_file(client)
      result = client.create_contents(@repo_path, @file_path, @commit_message, @content)
      format_success_result(result)
    end

    def handle_push_error(error)
      Rails.logger.error "GitHub file push failed: #{error.message}"
      { success: false, error: format_error_message(error) }
    end

    def content_unchanged?(existing_content)
      existing_content.strip == @content.strip
    end

    def skip_unchanged_content(existing_file)
      Rails.logger.info "Content unchanged, skipping GitHub push for #{@file_path}"
      {
        success: true,
        skipped: true,
        message: "内容に変更がないためプッシュをスキップしました",
        file_path: @file_path,
        repo_url: "https://github.com/#{@repo_path}",
        commit_sha: existing_file[:sha],
        html_url: existing_file[:html_url],
      }
    end

    def format_error_message(error)
      if error.message.include?("403") && error.message.include?("Resource not accessible by integration")
        "GitHubリポジトリへの書き込み権限がありません。" \
        "GitHub設定画面（https://github.com/settings/installations）で" \
        "DiaryCode Appの「Repository access」設定を確認し、" \
        "対象リポジトリ（#{@repo_path}）を選択してください。"
      else
        error.message
      end
    end

    def valid_for_push?
      @repo_path.present? && @file_path.present? && @content.present? &&
        @commit_message.present? && @access_token.present?
    end

    def format_success_result(result)
      {
        success: true,
        file_path: @file_path,
        repo_url: "https://github.com/#{@repo_path}",
        commit_sha: result[:commit][:sha],
        html_url: result[:content][:html_url],
      }
    end
end
