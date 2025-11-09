class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.string :author, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :stock, null: false, default: 0
      t.integer :format, null: false
      t.integer :condition, null: false
      t.date :removed_at
      t.date :inventory_entry_date, null: false

      t.timestamps
    end
  end
end
