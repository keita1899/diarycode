module ReportGithubIntegration
  extend ActiveSupport::Concern

  def should_push_to_github?(push_param)
    push_param == "1" && user.has_github_auth? && user.has_github_repo?
  end

  def push_to_github_with_messages(action_type)
    result = push_to_github

    success_action = (action_type == :create) ? "日報を保存" : "日報を更新"
    error_action = (action_type == :create) ? "日報は保存されました" : "日報は更新されました"

    if result[:success]
      if result[:skipped]
        { type: :notice, message: "#{success_action}しました。#{result[:message]}" }
      else
        { type: :notice, message: "#{success_action}し、GitHubにプッシュしました。" }
      end
    else
      { type: :alert, message: "#{error_action}が、GitHubプッシュに失敗しました: #{result[:error]}" }
    end
  end

  def github_pushed?
    github_push_status == "pushed" && github_pushed_at.present?
  end

  def github_push_failed?
    github_push_status == "failed"
  end

  def push_to_github
    return { success: false, error: "GitHubリポジトリが設定されていません" } unless user.has_github_repo?

    begin
      github_app = GithubApp.new
      installation_status = github_app.check_installation(user.github_repo_name)
      return { success: false, error: installation_status[:error] } unless installation_status[:installed]

      access_token = github_app.create_installation_access_token(installation_status[:installation_id])
      github_file = build_github_file(access_token)

      process_github_push(github_file)
    rescue => e
      handle_github_push_error(e)
    end
  end

  private

    def build_github_file(access_token)
      GithubFile.new(
        repo_path: user.github_repo_name,
        file_path: "#{date.strftime("%Y/%m/%d")}.md",
        content: format_push_report,
        commit_message: github_commit_message,
        access_token: access_token,
      )
    end

    def github_commit_message
      if github_pushed?
        "Update daily report for #{date.strftime("%Y-%m-%d")}"
      else
        "Add daily report for #{date.strftime("%Y-%m-%d")}"
      end
    end

    def process_github_push(github_file)
      result = github_file.push

      if result[:success]
        handle_successful_push(result)
      else
        mark_github_push_failed!
      end

      result
    end

    def handle_successful_push(result)
      skipped = result[:skipped] || false
      mark_github_pushed!(
        commit_sha: result[:commit_sha],
        file_url: result[:html_url],
        skipped: skipped,
      )
    end

    def handle_github_push_error(error)
      Rails.logger.error "GitHub push failed: #{error.message}"
      mark_github_push_failed!
      { success: false, error: error.message }
    end

    def format_push_report
      author_name = user.github_username || user.email

      <<~MARKDOWN
        # #{date.strftime("%Y年%m月%d日")}

        #{body}

        **作成者:** #{author_name}#{"  "}
      MARKDOWN
    end
end
