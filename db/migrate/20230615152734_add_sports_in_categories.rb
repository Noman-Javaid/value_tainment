class AddSportsInCategories < ActiveRecord::Migration[6.1]
  def change
    Category.create(name: 'Sports', status: 'active')
  end
end
