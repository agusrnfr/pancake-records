require 'prawn'
require 'prawn/table'

class SalePdf < Prawn::Document
  def initialize(sale)
    super(page_size: 'A4', page_layout: :portrait, margin: [40, 40, 40, 40])
    @sale = sale
    build_pdf
  end

  def build_pdf
    header
    move_down 20
    sale_info
    move_down 15
    buyer_info
    move_down 15
    products_table
    move_down 20
    footer
  end

  private

  def header
    text "Pancake Records", size: 24, style: :bold, align: :center
    text "Comprobante de Venta", size: 18, align: :center
    move_down 10
    stroke_horizontal_rule
  end

  def sale_info
    data = [
      ["Número de Venta:", "##{@sale.id}"],
      ["Fecha:", @sale.date.strftime("%d/%m/%Y")],
      ["Empleado:", "#{@sale.employee.name} #{@sale.employee.surname}"],
      ["Email del empleado:", @sale.employee.email],
      ["Estado:", @sale.is_cancelled? ? "Cancelada" : "Activa"]
    ]

    table(data, column_widths: [140, 315]) do
      cells.border_width = 0
      columns(0).font_style = :bold
      columns(0).background_color = "F0F0F0"
    end
  end

  def buyer_info
    text "Datos del Comprador", size: 14, style: :bold
    move_down 5
    
    data = [
      ["Nombre:", "#{@sale.buyer_name} #{@sale.buyer_surname}"],
      ["Teléfono:", @sale.buyer_phone.presence || "No especificado"],
      ["Email:", @sale.buyer_email.presence || "No especificado"],
      ["Dirección:", @sale.buyer_address.presence || "No especificada"]
    ]

    table(data, column_widths: [100, 355]) do
      cells.border_width = 0
      columns(0).font_style = :bold
    end
  end

  def products_table
    text "Productos Vendidos", size: 14, style: :bold
    move_down 5

    products_grouped = @sale.sale_products.group_by(&:product_id)
    
    table_data = [["Producto", "Autor", "Cantidad", "Precio Unitario", "Subtotal"]]
    
    products_grouped.each do |product_id, sale_products_list|
      product = sale_products_list.first.product
      quantity = sale_products_list.count
      unit_price = sale_products_list.first.unit_price
      subtotal = unit_price * quantity
      
      table_data << [
        product.name,
        product.author,
        quantity.to_s,
        format_currency(unit_price),
        format_currency(subtotal)
      ]
    end

    # Fila de totales
    table_data << [
      { content: "TOTAL", colspan: 4, align: :center, font_style: :bold },
      { content: format_currency(@sale.total), align: :center, font_style: :bold }
    ]

    table(table_data, header: true, column_widths: [130, 110, 50, 90, 90]) do
      # Estilo para todas las celdas
      cells.border_width = 1
      cells.border_color = "CCCCCC"
      cells.padding = 5
      cells.size = 9
      cells.align = :center
      cells.valign = :center
      
      # Encabezado
      row(0).font_style = :bold
      row(0).background_color = "E0E0E0"
      
      # Fila de totales
      row(-1).background_color = "FFF9E6"
      row(-1).font_style = :bold
    end

    move_down 10
    text "Total de productos: #{@sale.sale_products.count} | Productos únicos: #{products_grouped.count}", size: 10, style: :italic
  end

  def footer
    move_down 20
    stroke_horizontal_rule
    move_down 5
    text "Gracias por su compra", size: 12, align: :center, style: :italic
    text "Generado el #{Time.current.strftime("%d/%m/%Y %H:%M")}", size: 8, align: :center, style: :italic
  end

  def format_currency(amount)
    "$#{amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end
end

