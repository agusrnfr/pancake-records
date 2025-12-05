class AddQuantityToSaleProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :sale_products, :quantity, :integer, null: false, default: 1
  end
end

