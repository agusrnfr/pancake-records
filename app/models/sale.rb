class Sale < ApplicationRecord
	belongs_to :employee, class_name: "User"
  has_many :sale_products
  has_many :products, through: :sale_products

  validates :date, :total, presence: true
end
