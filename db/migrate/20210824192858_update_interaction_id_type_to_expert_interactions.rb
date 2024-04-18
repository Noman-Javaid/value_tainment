class UpdateInteractionIdTypeToExpertInteractions < ActiveRecord::Migration[6.1]
  def up
    execute 'DELETE FROM quick_questions;'
    execute 'DELETE FROM expert_calls;'
    execute 'DELETE FROM expert_interactions;'
    add_column :expert_interactions, :interaction_uuid, :uuid, null: false # rubocop:todo Rails/NotNullColumn
    remove_index :expert_interactions, name: 'index_expert_interactions_on_interaction'
    rename_column :expert_interactions, :interaction_id, :integer_id
    rename_column :expert_interactions, :interaction_uuid, :interaction_id
    add_index :expert_interactions, %i[interaction_type interaction_id], name: 'index_expert_interactions_on_interaction'
    remove_column :expert_interactions, :integer_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
