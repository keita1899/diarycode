class Report < ApplicationRecord
  belongs_to :user

  validates :date, presence: true, uniqueness: { scope: :user_id, message: "の日報は既に作成されています" }
  validates :body, presence: true
end
