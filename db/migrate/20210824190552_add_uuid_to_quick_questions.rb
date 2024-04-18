class AddUuidToQuickQuestions < ActiveRecord::Migration[6.1]
  def up
    add_column :quick_questions, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    rename_column :quick_questions, :id, :integer_id
    rename_column :quick_questions, :uuid, :id
    execute 'ALTER TABLE quick_questions drop constraint quick_questions_pkey;'
    execute 'ALTER TABLE quick_questions ADD PRIMARY KEY (id);'
    execute 'ALTER TABLE ONLY quick_questions ALTER COLUMN integer_id DROP DEFAULT;'
    remove_column :quick_questions, :integer_id
    execute 'DROP SEQUENCE IF EXISTS quick_questions_id_seq'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
