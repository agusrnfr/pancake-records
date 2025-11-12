class CreateUsers < ActiveRecord::Migration[8.1]
  def change
  	create_table :users do |t|
      t.string :name, null: false
      t.string :surname, null: false
      t.string :email, null: false, index: { unique: true }
      t.string :address
      t.integer :role, default: 1, null: false # default: employee

      t.timestamps
    end
  end
end
