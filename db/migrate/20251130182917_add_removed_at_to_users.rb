class AddRemovedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :removed_at, :datetime
  end
end
