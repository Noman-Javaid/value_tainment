class UpdateSlugPattern < ActiveRecord::Migration[6.1]
  def change
    Expert.find_each do |expert|
      expert.generate_slug
      expert.save
    end
  end
end
