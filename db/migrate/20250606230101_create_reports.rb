class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.text :body, null: false

      t.timestamps
    end
    
    add_index :reports, [:user_id, :date], unique: true
  end
end 