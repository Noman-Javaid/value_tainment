class AddNameIndexToUsers < ActiveRecord::Migration[6.1]
  def change
    add_index :users, "to_tsvector('simple', first_name || ' ' || last_name)", using: :gin, name: 'users_name_idx'
  end
end
