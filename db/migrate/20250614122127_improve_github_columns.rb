class ImproveGithubColumns < ActiveRecord::Migration[7.1]
  def up
    add_index :users, :github_username, unique: true, if_not_exists: true

    change_column_default :reports, :github_push_status, from: nil, to: "not_pushed"
    change_column :reports, :github_commit_sha, :string, limit: 64
    change_column :reports, :github_file_url, :text
    add_index :reports, :github_push_status, if_not_exists: true

    execute <<~SQL
      UPDATE reports SET github_push_status = 'not_pushed'
      WHERE github_push_status IS NULL
    SQL
  end

  def down
    remove_index :users, :github_username, if_exists: true

    change_column_default :reports, :github_push_status, from: "not_pushed", to: nil
    change_column :reports, :github_commit_sha, :string
    change_column :reports, :github_file_url, :string
    remove_index :reports, :github_push_status, if_exists: true
  end
end