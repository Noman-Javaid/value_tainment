class CreateAvailabilities < ActiveRecord::Migration[6.1]
  def change
    create_table :availabilities do |t|
      t.references :expert, index: { unique: true }, null: false, foreign_key: true, type: :uuid
      t.boolean :monday, null: false, default: false
      t.boolean :tuesday, null: false, default: false
      t.boolean :wednesday, null: false, default: false
      t.boolean :thursday, null: false, default: false
      t.boolean :friday, null: false, default: false
      t.boolean :saturday, null: false, default: false
      t.boolean :sunday, null: false, default: false
      t.string :time_start_weekday
      t.string :time_end_weekday
      t.string :time_start_weekend
      t.string :time_end_weekend

      t.timestamps
    end
  end
end
