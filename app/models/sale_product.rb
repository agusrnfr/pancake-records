class SaleProduct < ApplicationRecord
	belongs_to :sale
  belongs_to :product

	validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :product_must_exist
  validate :product_must_be_available
  validate :product_must_have_stock

  before_create :lock_product_and_validate_stock
  after_create :decrement_product_stock
  after_destroy :increment_product_stock

  private

  def product_must_exist
    unless product
      errors.add(:product, "no encontrado")
    end
  end

  def product_must_be_available
    return unless product

    if product.removed_at.present?
      errors.add(:product, "#{product.name} está eliminado y no se puede vender")
    end
  end

  def product_must_have_stock
    return unless product
    return unless sale
    return unless quantity

    # Recargar el producto para obtener el stock actual
    current_product = Product.find_by(id: product_id)
    return unless current_product
    
    # Sumar las cantidades de sale_products del mismo producto ya guardados
    already_saved_quantity = sale.sale_products.where(product_id: product_id).where.not(id: nil).sum(:quantity)
    
    # Calcular el stock original sumando las cantidades ya guardadas al stock actual
    original_stock = current_product.stock + already_saved_quantity
    
    # Sumar TODAS las cantidades de sale_products del mismo producto que se van a crear en esta venta
    # (tanto los guardados como los que están en memoria)
    total_quantity_to_create = sale.sale_products.select { |sp| sp.product_id == product_id }.sum(&:quantity)

    if original_stock < total_quantity_to_create
      errors.add(:product, "No hay stock suficiente para #{current_product.name}. Solicitado: #{total_quantity_to_create}, Disponible: #{original_stock}")
    end
  end

  def lock_product_and_validate_stock
    # Lock del producto y recargar para obtener el stock actual
    locked_product = Product.lock.find_by(id: product_id)
    
    unless locked_product
      errors.add(:product, "no encontrado")
      throw(:abort)
    end
    
    # Sumar TODAS las cantidades de sale_products del mismo producto que se van a crear en esta venta
    # (tanto los guardados como los que están en memoria)
    total_quantity_to_create = sale.sale_products.select { |sp| sp.product_id == product_id }.sum(&:quantity)

    # Necesitamos considerar el stock original, no el actual (que puede haber sido decrementado)
    # Para esto, sumamos las cantidades ya guardadas al stock actual
    already_saved_quantity = sale.sale_products.where(product_id: product_id).where.not(id: nil).sum(:quantity)
    original_stock = locked_product.stock + already_saved_quantity

    if original_stock < total_quantity_to_create
      errors.add(:product, "No hay stock suficiente para #{locked_product.name}. Solicitado: #{total_quantity_to_create}, Disponible: #{original_stock}")
      throw(:abort)
    end
  end

  def decrement_product_stock
    return unless product
    return unless quantity

    # Decrementar el stock por la cantidad vendida
    product.decrement!(:stock, quantity)
    
    # Validar que el stock no quede negativo
    if product.stock < 0
      errors.add(:base, "Error: El stock de #{product.name} quedó negativo")
      raise ActiveRecord::RecordInvalid.new(self)
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, "Error: El stock de #{product.name} quedó negativo")
    raise ActiveRecord::RecordInvalid.new(self)
  end

  def increment_product_stock
    return unless product
    return unless quantity

    product.increment!(:stock, quantity)
  end
end
