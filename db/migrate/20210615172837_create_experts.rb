class CreateExperts < ActiveRecord::Migration[6.1]
  def change
    create_table :experts do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
