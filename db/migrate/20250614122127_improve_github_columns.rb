class ImproveGithubColumns < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :github_username, unique: true

    change_column_default :reports, :github_push_status, from: nil, to: "not_pushed"
    
    change_column :reports, :github_commit_sha, :string, limit: 64
    
    change_column :reports, :github_file_url, :text
    
    add_index :reports, :github_push_status
    
    reversible do |dir|
      dir.up do
        Report.where(github_push_status: nil).update_all(github_push_status: "not_pushed")
      end
    end
  end
end
