class DropCategoriesExpertsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :categories_experts # rubocop:todo Rails/ReversibleMigration
  end
end
