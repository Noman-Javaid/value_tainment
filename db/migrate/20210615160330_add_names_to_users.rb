class AddNamesToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :first_name, :string # rubocop:todo Rails/BulkChangeTable
    add_column :users, :last_name, :string
  end
end
