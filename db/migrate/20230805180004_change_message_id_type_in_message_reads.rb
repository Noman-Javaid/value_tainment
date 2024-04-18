class ChangeMessageIdTypeInMessageReads < ActiveRecord::Migration[6.1]
  def change
    add_column :messages, :uuid, :uuid, default: "gen_random_uuid()", null: false

    change_table :messages do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE messages ADD PRIMARY KEY (id);"
  end
end
