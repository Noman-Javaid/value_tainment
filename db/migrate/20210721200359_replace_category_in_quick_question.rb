class ReplaceCategoryInQuickQuestion < ActiveRecord::Migration[6.1]
  def up
    add_reference :quick_questions, :category

    QuickQuestion.find_each do |quick_question|
      category = Category.find_by(name: quick_question.attributes_before_type_cast['category'])
      quick_question.update(category_id: category.id) if category
    end

    remove_column :quick_questions, :category, :string, null: false
  end

  def down
    remove_reference :quick_questions, :category
    add_column :quick_questions, :category, :string, null: false # rubocop:todo Rails/NotNullColumn
  end
end
