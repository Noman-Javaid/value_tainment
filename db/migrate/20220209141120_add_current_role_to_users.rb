class AddCurrentRoleToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :current_role, :integer, default: 0, null: false
    User.find_each do |user|
      if user.expert && user.individual.nil?
        user.update!(current_role: 1)
      elsif user.admin?
        user.update!(current_role: 2)
      end
    end
  end
end
