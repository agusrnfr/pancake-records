class Backoffice::SalesController < Backoffice::BaseController
  before_action :set_sale, only: [:show, :cancel]
  load_and_authorize_resource

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
    @available_products = Product.available_for_sale
  rescue => e
    @available_products = []
  end

  def create
    @sale = Sale.new(sale_params)
    @sale.employee = current_user

    if @sale.save
      redirect_to backoffice_sales_path, notice: "Venta creada correctamente"
    else
      @available_products = Product.available_for_sale
      render :new, status: :unprocessable_entity
    end
  rescue => e
    @sale ||= Sale.new
    @sale.errors.add(:base, "Error al crear la venta: #{e.message}")
    @available_products = Product.available_for_sale
    render :new, status: :unprocessable_entity
  end

  def cancel
    if @sale.is_cancelled?
      redirect_to backoffice_sales_path, alert: "La venta ya está cancelada"
      return
    end

    # Usar transacción para asegurar atomicidad
    ActiveRecord::Base.transaction do
      # Sumar las cantidades de sale_products por cada producto y restaurar stock
      product_quantities = @sale.sale_products.group(:product_id).sum(:quantity)

      product_quantities.each do |product_id, total_quantity|
        product = Product.find_by(id: product_id)
        next unless product

        # Incrementar el stock por la cantidad total de productos vendidos
        product.increment!(:stock, total_quantity)
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
      :buyer_address,
      sale_products_attributes: [:id, :product_id, :quantity, :_destroy]
    )
  end
end
