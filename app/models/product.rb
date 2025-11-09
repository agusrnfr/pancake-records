class Product < ApplicationRecord
	has_and_belongs_to_many :genres
  has_many :sale_products
  has_many :sales, through: :sale_products

	has_many_attached :images
  has_one_attached :audio_sample

  enum format: { vinyl: 0, cd: 1 }
  enum condition: { used: 0, new: 1 }

  validates :name, :author, :price, :stock, presence: true
	validates :price, numericality: { greater_than_or_equal_to: 0 }
end
