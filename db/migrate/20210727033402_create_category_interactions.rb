class CreateCategoryInteractions < ActiveRecord::Migration[6.1]
  def change
    create_table :category_interactions do |t|
      t.references :category, null: false, foreign_key: true
      t.references :interaction, polymorphic: true, null: false

      t.timestamps
    end

    add_column :categories, :interactions_count, :integer, null: false, default: 0
  end
end
