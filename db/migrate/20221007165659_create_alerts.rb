class CreateAlerts < ActiveRecord::Migration[6.1]
  def change
    create_table :alerts do |t|
      t.references :alertable, type: :uuid, polymorphic: true, null: false
      t.string :message
      t.integer :alert_type
      t.string :note
      t.string :status

      t.timestamps
    end
  end
end
