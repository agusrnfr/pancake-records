module Reports
  class SalesReportPdf
    include Prawn::View

    def initialize(from:, to:, total_amount:, total_count:, sales_by_day:, summary_by_product:)
      @from = from
      @to = to
      @total_amount = total_amount
      @total_count = total_count
      @sales_by_day = sales_by_day
      @summary_by_product = summary_by_product

      setup_document
      header_section
      kpi_section
      daily_sales_table
      products_table
    end

    private

    def setup_document
      font_families.update(
        "Helvetica" => {
          normal: "Helvetica",
          bold: "Helvetica-Bold"
        }
      )
      font "Helvetica"
      text "Pancake Records", size: 24, style: :bold, align: :center
      text "Reporte de Ventas", size: 18, align: :center
      move_down 10
      stroke_horizontal_rule
			move_down 10
    end

    def header_section
      text "Período: #{@from} a #{@to}", size: 10
      move_down 5
      text "Generado el: #{I18n.l(Date.current)}", size: 10
      move_down 15
    end

    def kpi_section
      data = [
        ["Monto total vendido", format_money(@total_amount)],
        ["Cantidad de ventas", @total_count.to_s],
        ["Ticket promedio", format_money(ticket_average)]
      ]

      table(data, header: false, cell_style: { size: 10, padding: [4, 6, 4, 6] }) do
        column(0).font_style = :bold
        rows(0..-1).borders = []
      end

      move_down 15
    end

    def daily_sales_table
      return if @sales_by_day.blank?

      text "Ventas por día", style: :bold, size: 12
      move_down 6

      headers = ["Fecha", "Monto vendido"]
      rows = @sales_by_day.sort_by { |date, _| date }.map do |date, amount|
        [I18n.l(date.to_date), format_money(amount)]
      end

      table([headers] + rows, header: true, width: bounds.width, cell_style: { size: 9 }) do
        row(0).font_style = :bold
        row(0).background_color = "F3F4F6"
        self.row_colors = ["FFFFFF", "F9FAFB"]
        self.header = true
      end

      move_down 15
    end

    def products_table
      return if @summary_by_product.blank?

      start_new_page if cursor < 150

      text "Detalle por producto", style: :bold, size: 12
      move_down 6

      headers = ["Producto", "Unidades vendidas", "Ingresos", "Ticket promedio por unidad"]
      rows = @summary_by_product.map do |row|
        units = row.units_sold.to_i
        revenue = row.revenue.to_f
        avg = units.positive? ? (revenue / units) : 0

        [
          row.name.to_s,
          units.to_s,
          format_money(revenue),
          format_money(avg)
        ]
      end

      table([headers] + rows, header: true, width: bounds.width, cell_style: { size: 9 }) do
        row(0).font_style = :bold
        row(0).background_color = "F3F4F6"
        self.row_colors = ["FFFFFF", "F9FAFB"]
        self.header = true
      end
    end

    def ticket_average
      return 0 unless @total_count.to_i.positive?

      @total_amount.to_f / @total_count.to_i
    end

    def format_money(amount)
      "$#{amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    end
  end
end


