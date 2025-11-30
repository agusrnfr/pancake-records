class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :sales, foreign_key: :employee_id, dependent: :nullify

  has_one_attached :avatar

  enum :role, { administrator: 0, employee: 1, manager: 2 }

  # Scopes para eliminación lógica
  scope :not_removed, -> { where(removed_at: nil) }
  scope :removed, -> { where.not(removed_at: nil) }

  validates :email, presence: true, uniqueness: true
  validates :name, :surname, :address, presence: true
  validate :validate_role_assignment, if: -> { assigned_by.present? && role_changed? }
  
  attr_accessor :assigned_by

  ROLE_PERMISSIONS = {
    administrator: %w[administrator manager employee],
    manager: %w[manager employee],
    employee: []
  }.freeze

	def role_name
    I18n.t("activerecord.enums.user.role.#{role}")
  end

  def self.filtered(params)
    scope = not_removed # Por defecto solo usuarios no eliminados
    scope = scope.where("email LIKE ?", "%#{params[:email]}%") if params[:email].present?
    scope = scope.where("surname LIKE ?", "%#{params[:surname]}%") if params[:surname].present?
    scope = scope.where("name LIKE ?", "%#{params[:name]}%") if params[:name].present?
    scope = scope.where(role: params[:role]) if params[:role].present?
    scope
  end

  def remove!
    update_column(:removed_at, Time.current)
  end

  def restore!
    update_column(:removed_at, nil)
  end

  def removed?
    removed_at.present?
  end

  # check de login de usuarios eliminados lógicamente
  def active_for_authentication?
    super && !removed?
  end

  def inactive_message
    removed? ? :removed : super
  end
  
  def self.assignable_roles_for(user)
    ROLE_PERMISSIONS[user.role.to_sym]
  end
  
  private
  
  def validate_role_assignment    
    return if  ROLE_PERMISSIONS[assigned_by.role.to_sym].include?(role)
    
    errors.add(:role, "No tienes permiso para asignar el rol de #{role}")
  end
  
end
