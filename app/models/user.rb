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

  scope :whth_email, ->(email) {
    return all if email.blank? || !emails.keys.include?(email)
    where(email: emails[email])
  }

  scope :with_surname, ->(surname) {
    return all if surname.blank? || !surnames.keys.include?(surname)
    where(surname: surnames[surname])
  }

  scope :with_name, ->(name) {
    return all if name.blank? || !names.keys.include?(name)
    where(name: names[name])
  }

  scope :with_role, ->(role) {
    return all if role.blank? || !roles.keys.include?(role)
    where(role: roles[role])
  }

end
