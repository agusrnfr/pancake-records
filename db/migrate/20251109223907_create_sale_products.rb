class CreateSaleProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :sale_products do |t|
      t.references :sale, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
			t.decimal :unit_price, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
