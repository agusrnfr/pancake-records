class AddPositionToActiveStorageAttachments < ActiveRecord::Migration[8.1]
  def change
    add_column :active_storage_attachments, :position, :integer, default: 0, null: false
    add_index :active_storage_attachments,
              [:record_type, :record_id, :name, :position],
              name: "index_active_storage_attachments_on_record_and_position"
  end
end


