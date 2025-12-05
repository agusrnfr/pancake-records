class Backoffice::Reports::SalesController < Backoffice::BaseController
  def index
    @from_date = parse_date(params[:from]) || 30.days.ago.to_date
    @to_date   = parse_date(params[:to])   || Date.current

    scope = Sale.where(date: @from_date.beginning_of_day..@to_date.end_of_day)

    scope = scope.where(is_cancelled: [false, nil]) if Sale.column_names.include?("is_cancelled")

    @total_sales_amount = scope.sum(:total)
    @total_sales_count  = scope.count

    @sales_by_day = scope.group(:date).sum(:total)

    sales_ids = scope.select(:id)

    sale_products_scope = SaleProduct.joins(:sale, :product)
                                     .where(sales: { id: sales_ids })

    @top_products = sale_products_scope
                      .group("products.id", "products.name")
                      .select(
                        "products.id AS product_id, products.name, SUM(sale_products.quantity) AS units_sold"
                      )
                      .order("units_sold DESC")
                      .limit(5)

    @top_products_chart_data = @top_products.map do |row|
      ["#{row.name} (##{row.product_id})", row.units_sold.to_i]
    end

    @sales_summary_by_product = sale_products_scope
                                  .group("products.id", "products.name")
                                  .select(
                                    "products.id AS product_id, products.name, " \
                                    "SUM(sale_products.quantity) AS units_sold, " \
                                    "SUM(sale_products.unit_price * sale_products.quantity) AS revenue"
                                  )

    respond_to do |format|
      format.html
      format.pdf do
        pdf = Reports::SalesReportPdf.new(
          from: @from_date,
          to: @to_date,
          total_amount: @total_sales_amount,
          total_count: @total_sales_count,
          sales_by_day: @sales_by_day,
          summary_by_product: @sales_summary_by_product
        )

        send_data pdf.render,
                  filename: "reporte_ventas_#{@from_date}_#{@to_date}.pdf",
                  type: "application/pdf",
                  disposition: "attachment"
      end
    end
  end

  private

  def parse_date(value)
    return nil if value.blank?

    Date.parse(value) rescue nil
  end
end


