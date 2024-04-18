class CreateAttachment < ActiveRecord::Migration[6.1]
  def change
    create_table :attachments do |t|
      t.references :quick_question, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
