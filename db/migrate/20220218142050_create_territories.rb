class CreateTerritories < ActiveRecord::Migration[6.1]
  def change
    create_table :territories do |t|
      t.string :name, null: false
      t.string :alpha2_code, null: false
      t.string :phone_code, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :territories, :name, unique: true
    add_index :territories, :alpha2_code, unique: true
  end
end
