class AddUsernameToIndivuduals < ActiveRecord::Migration[6.1]
  def change
    add_column :individuals, :username, :string
  end
end
