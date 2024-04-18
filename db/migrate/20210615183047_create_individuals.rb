class CreateIndividuals < ActiveRecord::Migration[6.1]
  def change
    create_table :individuals do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
