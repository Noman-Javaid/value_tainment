class AddNewColumnsInUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :phone, :string
    add_column :users, :country_code, :string, default: '+1'

    User.all.each do |user|
      if user.phone_number.present?
        user.update(phone: user.phone_number[1..-1], country_code: '+1')
      end
    end
  end
end
