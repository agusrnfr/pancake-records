class CreateSales < ActiveRecord::Migration[8.1]
  def change
    create_table :sales do |t|
      t.date :date, null: false
      t.decimal :total, precision: 10, scale: 2, null: false
      t.references :employee, null: false, foreign_key: { to_table: :users }
      t.string :buyer_name, null: false
      t.string :buyer_surname, null: false
      t.string :buyer_phone
      t.string :buyer_email
      t.string :buyer_address
      t.boolean :is_cancelled, default: false, null: false

      t.timestamps
    end
  end
end
