class AddSocialMediaFieldsToExperts < ActiveRecord::Migration[6.1]
  def change
    add_column :experts, :twitter_url, :string # rubocop:todo Rails/BulkChangeTable
    add_column :experts, :instagram_url, :string
  end
end
