class CreateGuestInCalls < ActiveRecord::Migration[6.1]
  def change
    create_table :guest_in_calls do |t|
      t.references :individual, null: false, foreign_key: true, type: :uuid
      t.references :expert_call, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
