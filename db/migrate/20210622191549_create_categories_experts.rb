class CreateCategoriesExperts < ActiveRecord::Migration[6.1]
  def change
    create_table :categories_experts do |t|
      t.references :expert, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
