class CreateComplaints < ActiveRecord::Migration[6.1]
  def change
    create_table :complaints do |t|
      t.references :individual, null: false, foreign_key: true, type: :uuid
      t.references :expert, null: false, foreign_key: true, type: :uuid
      t.references :expert_interaction, foreign_key: true
      t.text :content
      t.string :status, null: false, default: 'requires_verification'

      t.timestamps
    end
  end
end
