class User < ApplicationRecord
	has_secure_password

  has_many :sales, foreign_key: :employee_id, dependent: :nullify

  has_one_attached :avatar

  enum role: { administrator: 0, employee: 1, manager: 2 }

  validates :email, presence: true, uniqueness: true
end
