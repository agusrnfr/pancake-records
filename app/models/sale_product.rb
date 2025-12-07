class SaleProduct < ApplicationRecord
  belongs_to :sale
  belongs_to :product

  validates :product, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :product_id, uniqueness: { scope: :sale_id, message: "ya está en la lista de venta" }

  validate :product_must_be_active
  validate :stock_availability, if: -> { new_record? || quantity_changed? }

  before_validation :set_unit_price
  after_create :decrement_stock
  after_destroy :increment_stock

  def restore_stock
    product.increment!(:stock, quantity) if product
  end 

  def total_line_price
    price = unit_price || product&.price || 0
    (price * (quantity || 0))
  end

  private

  def set_unit_price
    self.unit_price ||= product&.price if product.present?
  end

  def product_must_be_active
    if product&.removed_at.present?
      errors.add(:product, "#{product.name} está eliminado y no se puede vender")
    end
  end

  def stock_availability
    return unless product && quantity


    if product.stock < quantity
      errors.add(:base, "No hay suficiente stock de #{product.name}. Solicitado: #{quantity}, Disponible: #{product.stock}")
    end
  end

  def decrement_stock

    product.decrement!(:stock, quantity)
  rescue ActiveRecord::RecordInvalid
    errors.add(:base, "El stock cambió mientras se procesaba la venta")
    throw(:abort)
  end

  def increment_stock
    product.increment!(:stock, quantity)
  end
end