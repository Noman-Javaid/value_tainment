class CreateCategoriesExpertsJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_table :categories_experts do |t|
      t.references :category, null: false, foreign_key: true
      t.references :expert, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
    add_index :categories_experts, [:expert_id, :category_id], unique: true
  end
end
