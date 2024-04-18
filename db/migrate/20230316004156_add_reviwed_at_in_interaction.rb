class AddReviwedAtInInteraction < ActiveRecord::Migration[6.1]
  def change
    add_column :expert_interactions, :reviewed_at, :datetime
  end
end
