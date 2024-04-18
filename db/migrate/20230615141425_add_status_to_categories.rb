class AddStatusToCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :status, :string, default: 'Active'

    Category.update_all(status: 'inactive')
    Category.create(name: 'Business', status: 'active')
    Category.create(name: 'Celebrity', status: 'active')
    Category.create(name: 'Coaching', status: 'active')
    Category.create(name: 'Counseling', status: 'active')
    Category.create(name: 'Crypto', status: 'active')
    Category.create(name: 'Entrepreneurship', status: 'active')
    Category.create(name: 'Finance', status: 'active')
    Category.create(name: 'Health', status: 'active')
    Category.create(name: 'Legal', status: 'active')
    Category.create(name: 'Marketing', status: 'active')
    Category.create(name: 'Politics', status: 'active')
    Category.create(name: 'Real Estate', status: 'active')
    Category.create(name: 'Social Media', status: 'active')
    Category.create(name: 'Technology', status: 'active')
  end
end
