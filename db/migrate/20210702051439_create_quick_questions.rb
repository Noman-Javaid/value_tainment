class CreateQuickQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :quick_questions do |t|
      t.text :question, null: false
      t.text :answer
      t.string :payment_id, null: false
      t.string :payment_status, null: false
      t.string :refund_id
      t.references :expert, null: false, type: :uuid, foreign_key: true
      t.references :individual, null: false, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
