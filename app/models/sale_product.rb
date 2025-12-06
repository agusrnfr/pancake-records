class SaleProduct < ApplicationRecord
  belongs_to :sale
  belongs_to :product

  # 1. Validar que la venta y el producto existan
  validates :product, presence: true
  
  # 2. Validar que la cantidad sea un entero positivo
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # 3. ESTO ELIMINA LA LOGICA VIEJA: 
  # Impide que metas el mismo producto 2 veces en la misma venta.
  validates :product_id, uniqueness: { scope: :sale_id, message: "ya está en la lista de venta" }

  # 4. Validaciones custom
  validate :product_must_be_active
  validate :stock_availability

  # Callbacks
  before_validation :set_unit_price  # Congelar el precio al momento de la venta (antes de validación para que Sale pueda calcular el total)
  after_create :decrement_stock
  # Opcional: Si borras la venta/linea, devolver el stock
  after_destroy :increment_stock 

  # Método auxiliar para que el padre calcule el total
  def total_line_price
    price = unit_price || product&.price || 0
    (price * (quantity || 0))
  end

  private

  def set_unit_price
    # Solo asignar si no tiene precio (para no sobrescribir en ediciones)
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