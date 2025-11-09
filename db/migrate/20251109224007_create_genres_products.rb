class CreateGenresProducts < ActiveRecord::Migration[8.1]
	def change
    create_table :genres_products, id: false do |t|
      t.references :genre, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
    end

    add_index :genres_products, [:genre_id, :product_id], unique: true
  end
end
