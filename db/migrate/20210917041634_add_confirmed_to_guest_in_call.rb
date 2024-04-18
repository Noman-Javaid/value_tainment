class AddConfirmedToGuestInCall < ActiveRecord::Migration[6.1]
  def change
    add_column :guest_in_calls, :confirmed, :boolean
  end
end
