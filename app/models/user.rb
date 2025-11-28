class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :sales, foreign_key: :employee_id, dependent: :nullify

  has_one_attached :avatar

  enum :role, { administrator: 0, employee: 1, manager: 2 }

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :surname, presence: true
  validates :address, presence: true

	def role_name
    I18n.t("activerecord.enums.user.role.#{role}")
  end

  def self.filtered(params)
  results = all
  results = results.where("email LIKE ?", "%#{params[:email]}%") if params[:email].present?

  results = results.where("surname LIKE ?", "%#{params[:surname]}%") if params[:surname].present?

  results = results.where("name LIKE ?", "%#{params[:name]}%") if params[:name].present?

  results = results.where(role: params[:role]) if params[:role].present?

  results
end
  
end
