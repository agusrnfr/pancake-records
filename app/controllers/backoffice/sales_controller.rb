class Backoffice::SalesController < Backoffice::BaseController
  before_action :set_sale, only: [:show, :cancel]

  def index
    @q = Sale.ransack(params[:q])
    @sales = @q.result(distinct: true)
                 .order(created_at: :desc)
                 .page(params[:page])
                 .per(8)
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        pdf = SalePdf.new(@sale)
        send_data pdf.render,
          filename: "venta_#{@sale.id}_#{@sale.date.strftime('%Y%m%d')}.pdf",
          type: 'application/pdf',
          disposition: 'attachment'
      end
    end
  end

  def new
    @sale = Sale.new
    @sale.date = Date.current
    @available_products = Product.where(removed_at: nil).where("stock > 0").order(:name)
  rescue => e
    @available_products = []
  end

  def create
    @sale = Sale.new(sale_params)
    @sale.employee = current_user
    @sale.date ||= Date.current

    # Calcular el total y validar productos
    total = 0
    sale_products_data = []
    products_quantities = {} # Para rastrear cantidades por producto

    if params[:sale_products].present?
      params[:sale_products].each do |index, product_data|
        # Los parámetros vienen como hash con índices numéricos como strings
        product_id = product_data[:product_id]&.to_i || product_data["product_id"]&.to_i || 0
        quantity = product_data[:quantity]&.to_i || product_data["quantity"]&.to_i || 0

        next if product_id.zero? || quantity.zero?

        # Acumular cantidad por producto (por si el mismo producto aparece múltiples veces)
        products_quantities[product_id] = (products_quantities[product_id] || 0) + quantity
      end

      # Validar todos los productos antes de procesar
      products_quantities.each do |product_id, total_quantity|
        product = Product.find_by(id: product_id)
        
        unless product
          @sale.errors.add(:base, "Producto con ID #{product_id} no encontrado")
          @available_products = Product.where(removed_at: nil).where("stock > 0").order(:name)
          render :new, status: :unprocessable_entity
          return
        end

        # Validar que el producto no esté eliminado
        if product.removed_at.present?
          @sale.errors.add(:base, "El producto #{product.name} está eliminado y no se puede vender")
          @available_products = Product.where(removed_at: nil).where("stock > 0").order(:name)
          render :new, status: :unprocessable_entity
          return
        end

        # Validar que hay stock suficiente (validación crítica)
        if product.stock < total_quantity
          @sale.errors.add(:base, "No hay stock suficiente para #{product.name}. Solicitado: #{total_quantity}, Disponible: #{product.stock}")
          @available_products = Product.where(removed_at: nil).where("stock > 0").order(:name)
          render :new, status: :unprocessable_entity
          return
        end

        # Validar que la cantidad sea positiva
        if total_quantity <= 0
          @sale.errors.add(:base, "La cantidad para #{product.name} debe ser mayor a 0")
          @available_products = Product.where(removed_at: nil).where("stock > 0").order(:name)
          render :new, status: :unprocessable_entity
          return
        end

        # Calcular total y preparar datos para crear sale_products
        unit_price = product.price
        total += unit_price * total_quantity

        # Crear un SaleProduct por cada unidad vendida
        total_quantity.times do
          sale_products_data << {
            product_id: product_id,
            unit_price: unit_price
          }
        end
      end
    end

    if sale_products_data.empty?
      @sale.errors.add(:base, "Debe agregar al menos un producto a la venta")
      @available_products = Product.where(removed_at: nil).where("stock > 0").order(:name)
      render :new, status: :unprocessable_entity
      return
    end

    @sale.total = total

    # Usar transacción para asegurar atomicidad
    ActiveRecord::Base.transaction do
      # Validación final dentro de la transacción (por si el stock cambió)
      products_quantities.each do |product_id, total_quantity|
        product = Product.lock.find_by(id: product_id) # Lock para evitar condiciones de carrera
        
        unless product
          @sale.errors.add(:base, "Producto con ID #{product_id} no encontrado")
          raise ActiveRecord::Rollback
        end

        # Validación final de stock dentro de la transacción
        if product.stock < total_quantity
          @sale.errors.add(:base, "No hay stock suficiente para #{product.name}. Solicitado: #{total_quantity}, Disponible: #{product.stock}")
          raise ActiveRecord::Rollback
        end
      end

      # Si hay errores, no guardar
      if @sale.errors.any?
        @available_products = Product.where(removed_at: nil).where("stock > 0").order(:name)
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      if @sale.save
        # Crear los sale_products y decrementar stock
        sale_products_data.each do |sp_data|
          sale_product = @sale.sale_products.create!(
            product_id: sp_data[:product_id],
            unit_price: sp_data[:unit_price]
          )

          # Decrementar stock del producto
          product = sale_product.product
          product.decrement!(:stock)
          
          # Validar que el stock no sea negativo (seguridad adicional)
          if product.stock < 0
            @sale.errors.add(:base, "Error: El stock de #{product.name} quedó negativo")
            raise ActiveRecord::Rollback
          end
        end

        redirect_to backoffice_sales_path, notice: "Venta creada correctamente"
      else
        @available_products = Product.where(removed_at: nil).where("stock > 0").order(:name)
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  rescue => e
    @available_products = Product.where(removed_at: nil).where("stock > 0").order(:name)
    @sale.errors.add(:base, "Error al crear la venta: #{e.message}")
    render :new, status: :unprocessable_entity
  end

  def cancel
    if @sale.is_cancelled?
      redirect_to backoffice_sales_path, alert: "La venta ya está cancelada"
      return
    end

    # Usar transacción para asegurar atomicidad
    ActiveRecord::Base.transaction do
      # Contar cuántos sale_products hay por cada producto y restaurar stock
      product_counts = @sale.sale_products.group(:product_id).count

      product_counts.each do |product_id, count|
        product = Product.find_by(id: product_id)
        next unless product

        # Incrementar el stock por la cantidad de productos vendidos
        product.increment!(:stock, count)
      end

      @sale.update!(is_cancelled: true)
    end

    redirect_to backoffice_sales_path, notice: "Venta cancelada correctamente"
  rescue => e
    redirect_to backoffice_sales_path, alert: "Error al cancelar la venta: #{e.message}"
  end

  private

  def set_sale
    @sale = Sale.find(params[:id])
  end

  def sale_params
    params.require(:sale).permit(
      :date,
      :buyer_name,
      :buyer_surname,
      :buyer_phone,
      :buyer_email,
      :buyer_address
    )
  end
end
