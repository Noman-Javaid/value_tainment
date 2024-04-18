class AddFileAttributesToAttachments < ActiveRecord::Migration[6.1]
  def change
    change_table :attachments, bulk: true do |t|
      t.column :file_key, :string, null: false
      t.column :file_name, :string, null: false
      t.column :file_type, :string, null: false
      t.integer :file_size, null: false
      t.boolean :in_bucket, default: false, null: false
    end
  end
end
