class AddProfileFieldsToUserExpert < ActiveRecord::Migration[6.1]
  def change
    add_column :experts, :biography, :text # rubocop:todo Rails/BulkChangeTable
    add_column :experts, :website_url, :string
    add_column :experts, :linkedin_url, :string
    add_column :experts, :quick_question_rate, :integer
    add_column :experts, :one_to_one_video_call_rate, :integer
    add_column :experts, :one_to_five_video_call_rate, :integer
    add_column :experts, :extra_user_rate, :integer
  end
end
