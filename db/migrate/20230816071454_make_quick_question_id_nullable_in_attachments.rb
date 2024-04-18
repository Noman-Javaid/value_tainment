class MakeQuickQuestionIdNullableInAttachments < ActiveRecord::Migration[6.1]
  def change
    change_column :attachments, :quick_question_id, :uuid, null: true

  end
end
