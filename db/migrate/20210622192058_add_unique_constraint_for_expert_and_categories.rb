class AddUniqueConstraintForExpertAndCategories < ActiveRecord::Migration[6.1]
  def change
    add_index :categories_experts, [:expert_id, :category_id], unique: true
  end
end
