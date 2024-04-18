class DropExpertsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :experts # rubocop:todo Rails/ReversibleMigration
  end
end
