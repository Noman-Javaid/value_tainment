class AddConfirmableToDevise < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :confirmation_token, :string # rubocop:todo Rails/BulkChangeTable
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string
    # account_verified allows to track existing users that need to confirm account
    add_column :users, :account_verified, :boolean, default: false
    add_index :users, :confirmation_token, unique: true
    # User.reset_column_information # Need for some types of updates, but not for update_all.
    # To avoid a short time window between running the migration and updating all existing
    # users as confirmed, do the following
    User.update_all confirmed_at: DateTime.now # rubocop:todo Rails/SkipsModelValidations
    # All existing user accounts should be able to log in after this.
  end

  def down
    remove_index :users, :confirmation_token
    # rubocop:todo Rails/BulkChangeTable
    remove_columns :users, :confirmation_token, :confirmed_at, :confirmation_sent_at
    # rubocop:enable Rails/BulkChangeTable
    remove_columns :users, :unconfirmed_email
  end
end
