class CreateParticipantEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :participant_events do |t|
      t.references :expert_call, null: false, foreign_key: true, type: :uuid
      t.string :participant_id, null: false
      t.string :event_name, null: false
      t.integer :duration
      t.datetime :event_datetime, null: false
      t.boolean :initial, null: false, default: false
      t.boolean :expert, null: false, default: false

      t.timestamps
    end
  end
end
