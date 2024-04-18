class AddSlugInExpert < ActiveRecord::Migration[6.1]
  def change
    add_column :experts, :slug, :string
    add_index :experts, :slug, unique: true

    Expert.find_each do |expert|
      expert.generate_slug
      expert.save
    end
  end

end
