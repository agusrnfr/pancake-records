class SaleProduct < ApplicationRecord
	belongs_to :sale
  belongs_to :product

	validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

end
