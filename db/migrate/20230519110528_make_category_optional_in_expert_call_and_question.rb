class MakeCategoryOptionalInExpertCallAndQuestion < ActiveRecord::Migration[6.1]
  def change
    change_column :expert_calls, :category_id, :integer, null: true
    change_column :quick_questions, :category_id, :integer, null: true
  end
end
