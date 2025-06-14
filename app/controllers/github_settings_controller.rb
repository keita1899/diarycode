class GithubSettingsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user

    return unless @user.has_github_auth? && @user.has_github_repo?

    begin
      github_app = GithubApp.new
      @installation_status = github_app.check_installation(@user.github_repo_name)
      @installation_url = github_app.installation_url
    rescue Octokit::Unauthorized, Octokit::NotFound => e
      Rails.logger.error "GitHub App service error: #{e.message}"
      @github_app_error = "GitHub App設定に問題があります。環境変数を確認してください。"
    end
  end

  def update
    @user = current_user

    unless @user.has_github_auth?
      redirect_to edit_github_settings_path, alert: "GitHub認証が必要です。まず認証を完了してください。"
      return
    end

    if @user.update(github_params)
      redirect_to edit_github_settings_path, notice: "GitHub設定を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

    def github_params
      params.require(:user).permit(:github_repo_url)
    end
end
