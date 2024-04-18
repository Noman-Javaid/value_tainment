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
class Category < ApplicationRecord
  ## Associations
  has_and_belongs_to_many :experts

  has_many :quick_questions, dependent: :destroy
  has_many :category_interactions, dependent: :destroy

  ## Callbacks
  before_destroy :confirm_no_experts_associations

  ## Validations
  # rubocop:todo Rails/UniqueValidationWithoutIndex
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  # rubocop:enable Rails/UniqueValidationWithoutIndex

  enum status: { active: 'Active', inactive: 'Inactive' }

  ## Methods and helpers
  private

  def confirm_no_experts_associations
    return true if experts.empty?

    errors.add :experts, 'cannot delete category with experts'

    throw :abort
  end
end
