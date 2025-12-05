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

    @top_products = Product.joins(sale_products: :sale)
                           .where(sales: { id: sales_ids })
                           .group("products.id", "products.name")
                           .order("COUNT(sale_products.id) DESC")
                           .limit(5)
                           .count

    @sales_summary_by_product = Product.joins(sale_products: :sale)
                                       .where(sales: { id: sales_ids })
                                       .group("products.id", "products.name")
                                       .select(
                                         "products.id, products.name, COUNT(sale_products.id) AS units_sold, SUM(sale_products.unit_price) AS revenue"
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


