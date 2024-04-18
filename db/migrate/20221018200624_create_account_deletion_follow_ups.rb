class CreateAccountDeletionFollowUps < ActiveRecord::Migration[6.1]
  def change
    create_table :account_deletion_follow_ups do |t|
      t.references :user, null: true, foreign_key: true
      t.integer :status, default: 0
      t.string :stripe_customer_id
      t.string :stripe_account_id
      t.boolean :required_for_individual, default: false
      t.boolean :required_for_expert, default: false
      t.text :notes
      t.timestamps
    end
  end
end
