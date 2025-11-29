class Sale < ApplicationRecord
	belongs_to :employee, class_name: "User"
  has_many :sale_products
  has_many :products, through: :sale_products

  validates :date, :total, :employee_id, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["buyer_address", "buyer_email", "buyer_name", "buyer_phone", "buyer_surname", "created_at", "date", "employee_id", "id", "is_cancelled", "total", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["employee", "products", "sale_products"]
  end
end
