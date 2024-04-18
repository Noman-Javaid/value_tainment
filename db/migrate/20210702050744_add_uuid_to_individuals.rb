class AddUuidToIndividuals < ActiveRecord::Migration[6.1]
  def up
    add_column :individuals, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    rename_column :individuals, :id, :integer_id
    rename_column :individuals, :uuid, :id
    execute 'ALTER TABLE individuals drop constraint individuals_pkey;'
    execute 'ALTER TABLE individuals ADD PRIMARY KEY (id);'
    execute 'ALTER TABLE ONLY individuals ALTER COLUMN integer_id DROP DEFAULT;'
    remove_column :individuals, :integer_id
    execute 'DROP SEQUENCE IF EXISTS individuals_id_seq'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
