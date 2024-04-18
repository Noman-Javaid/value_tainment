class CreateReminders < ActiveRecord::Migration[6.1]
  def change
    create_table :reminders do |t|
      t.float :timer
      t.string :detail
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :reminders, [:timer, :active], unique: true
  end
end
