class SaleBuilder
  attr_reader :errors, :sale

  def initialize(sale_params:, employee:)
    @sale_params = sale_params
    @employee = employee
    @items = []
    @errors = []
  end

  def add_item(product:, quantity:)
    unless product
      @errors << "Producto no encontrado"
      return self
    end

    if quantity <= 0
      @errors << "La cantidad debe ser mayor a cero"
      return self
    end

    if product.removed_at.present?
      @errors << "El producto #{product.name} está eliminado y no se puede vender"
      return self
    end

    if quantity > product.stock
      @errors << "Stock insuficiente para #{product.name}. Solicitado: #{quantity}, Disponible: #{product.stock}"
      return self
    end

    @items << { product: product, quantity: quantity }
    self
  end

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      @sale = Sale.new(@sale_params)
      @sale.employee = @employee
      @sale.date ||= Date.current

      @items.each do |item|
        product = item[:product].reload

        if item[:quantity] > product.stock
          @errors << "El stock de #{product.name} cambió. Disponible: #{product.stock}"
          raise ActiveRecord::Rollback
        end

        @sale.sale_products.build(
          product: product,
          unit_price: product.price,
          quantity: item[:quantity]
        )
      end

      @sale.total = @sale.sale_products.sum { |sp| sp.unit_price * sp.quantity }

      unless @sale.save
        @errors.concat(@sale.errors.full_messages)
        raise ActiveRecord::Rollback
      end
    end

    @errors.empty?
  rescue => e
    @errors << e.message
    false
  end

  private

  def valid?
    if @items.empty?
      @errors << "Debe agregar al menos un producto a la venta"
      return false
    end

    @errors.empty?
  end
end
