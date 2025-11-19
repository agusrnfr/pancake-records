class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :sales, foreign_key: :employee_id, dependent: :nullify

  has_one_attached :avatar

  enum :role, { administrator: 0, employee: 1, manager: 2 }

  validates :email, presence: true, uniqueness: true

	def role_name
    I18n.t("activerecord.enums.user.role.#{role}")
  end

end
