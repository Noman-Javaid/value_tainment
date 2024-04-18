class CreateAppVersions < ActiveRecord::Migration[6.1]
  def change
    create_table :app_versions do |t|
      t.string :platform
      t.string :version
      t.boolean :force_update
      t.boolean :supported
      t.boolean :is_latest
      t.datetime :release_date
      t.datetime :support_ends_on

      t.timestamps
    end
  end
end
