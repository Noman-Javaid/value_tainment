class AddMessageToAttachments < ActiveRecord::Migration[6.1]
  def change
    add_reference :attachments, :message, null: true, foreign_key: true, type: :uuid

  end
end
