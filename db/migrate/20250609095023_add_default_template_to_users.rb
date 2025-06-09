class AddDefaultTemplateToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :default_template_id, :integer
  end
end
