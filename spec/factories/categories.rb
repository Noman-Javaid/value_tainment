# == Schema Information
#
# Table name: categories
#
#  id                 :bigint           not null, primary key
#  description        :string
#  interactions_count :integer          default(0), not null
#  name               :string
#  status             :string           default("active")
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category Name #{n}" }
    description { 'Category long description' }
  end
end
