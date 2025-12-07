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
    current_time = Time.current
    @sale.time = Time.new(2000, 1, 1, current_time.hour, current_time.min, 0)
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

    if @sale.cancel!
      redirect_to backoffice_sales_path, notice: "Venta cancelada correctamente"
    else
      redirect_to backoffice_sales_path, alert: "Error al cancelar la venta"
    end
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
      :time,
      :buyer_name,
      :buyer_surname,
      :buyer_phone,
      :buyer_email,
      :buyer_address,
      sale_products_attributes: [:id, :product_id, :quantity, :_destroy]
    )
  end
end
