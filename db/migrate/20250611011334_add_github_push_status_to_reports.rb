class AddGithubPushStatusToReports < ActiveRecord::Migration[7.1]
  def change
    add_column :reports, :github_pushed_at, :datetime
    add_column :reports, :github_push_status, :string
    add_column :reports, :github_commit_sha, :string
    add_column :reports, :github_file_url, :string
  end
end
