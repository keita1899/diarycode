class AddDefaultTemplateToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :default_template, foreign_key: { to_table: :templates }
  end
end
