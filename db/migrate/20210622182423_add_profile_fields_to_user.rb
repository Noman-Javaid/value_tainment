class AddProfileFieldsToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :date_of_birth, :date # rubocop:todo Rails/BulkChangeTable
    add_column :users, :gender, :string
    add_column :users, :phone_number, :string
    add_column :users, :country, :string
    add_column :users, :city, :string
    add_column :users, :zip_code, :string
  end
end
