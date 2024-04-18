class AddUuiDinReschedulingRequest < ActiveRecord::Migration[6.1]
  def change
    add_column :rescheduling_requests, :uuid, :uuid, default: "gen_random_uuid()", null: false

    change_table :rescheduling_requests do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE rescheduling_requests ADD PRIMARY KEY (id);"
  end
end
