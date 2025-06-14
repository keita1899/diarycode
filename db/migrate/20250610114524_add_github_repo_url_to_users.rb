class AddGithubRepoUrlToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :github_repo_url, :string
  end
end
