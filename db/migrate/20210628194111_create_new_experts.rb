class CreateNewExperts < ActiveRecord::Migration[6.1]
  def change
    create_table :experts, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true
      t.string :stripe_connected_account
      t.boolean :stripe_requirements_fulfilled, default: false
      t.boolean :can_receive_stripe_transfers, default: false
      t.integer :status, null: false, default: 0
      t.text :biography
      t.string :website_url
      t.string :linkedin_url
      t.integer :quick_question_rate
      t.integer :one_to_one_video_call_rate
      t.integer :one_to_five_video_call_rate
      t.integer :extra_user_rate

      t.timestamps
    end
  end
end
