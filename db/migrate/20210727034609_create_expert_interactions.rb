class CreateExpertInteractions < ActiveRecord::Migration[6.1]
  def change
    create_table :expert_interactions do |t|
      t.references :expert, null: false, foreign_key: true, type: :uuid
      t.references :interaction, polymorphic: true, null: false

      t.timestamps
    end

    add_column :experts, :interactions_count, :integer, null: false, default: 0 # rubocop:todo Rails/BulkChangeTable
    remove_column :experts, :consultation_count, :integer, default: 0
  end
end
