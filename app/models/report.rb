class Report < ApplicationRecord
  include ReportGithubIntegration

  belongs_to :user

  validates :date, presence: true, uniqueness: { scope: :user_id, message: "の日報は既に作成されています" }
  validates :body, presence: true

  enum github_push_status: {
    not_pushed: nil,
    pushed: "pushed",
    failed: "failed",
  }, _prefix: :github

  def self.build_for_user(user, date_param: nil)
    report = user.reports.build
    report.date = parse_date_param(date_param)
    report.apply_default_template
    report
  end

  def self.parse_date_param(date_param)
    return Date.current if date_param.blank?

    begin
      Date.parse(date_param)
    rescue ArgumentError
      Date.current
    end
  end

  def apply_default_template
    return unless user.default_template && body.blank?

    self.body = user.default_template.body
  end

  def mark_github_pushed!(commit_sha: nil, file_url: nil, skipped: false)
    update!(
      github_push_status: "pushed",
      github_pushed_at: skipped ? github_pushed_at : Time.current,
      github_commit_sha: commit_sha,
      github_file_url: file_url,
    )
  end

  def mark_github_push_failed!
    update!(
      github_push_status: "failed",
      github_pushed_at: nil,
      github_commit_sha: nil,
      github_file_url: nil,
    )
  end
end
