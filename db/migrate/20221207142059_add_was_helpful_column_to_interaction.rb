class AddWasHelpfulColumnToInteraction < ActiveRecord::Migration[6.1]
  def change
    add_column :expert_interactions, :was_helpful, :boolean, null: true
  end
end
