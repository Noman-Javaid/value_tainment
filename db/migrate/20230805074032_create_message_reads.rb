class CreateMessageReads < ActiveRecord::Migration[6.1]
  def change
    create_table :message_reads, id: :uuid do |t|
      t.references :reader, polymorphic: true, type: :uuid
      t.references :message, type: :uuid
      t.timestamps
    end
  end
end
