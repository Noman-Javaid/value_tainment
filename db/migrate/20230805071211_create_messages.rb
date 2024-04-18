class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.string :text
      t.references :sender, null: false, type: :uuid, polymorphic: true
      t.string :content_type
      t.references :attachment, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
