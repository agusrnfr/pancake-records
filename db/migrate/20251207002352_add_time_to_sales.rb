class AddTimeToSales < ActiveRecord::Migration[8.1]
  def change
    add_column :sales, :time, :time
  end
end
