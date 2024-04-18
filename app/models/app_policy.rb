# == Schema Information
#
# Table name: app_policies
#
#  id          :bigint           not null, primary key
#  description :string           default([]), is an Array
#  expert      :boolean
#  global      :boolean          default(FALSE)
#  has_changed :boolean          default(TRUE)
#  individual  :boolean
#  status      :string           default("active")
#  title       :string           not null
#  version     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class AppPolicy < ApplicationRecord
  enum status: { active: 'active', inactive: 'inactive' }
  enum title: { 'Cancellation Policy': 'Cancellation Policy',
                'Rescheduling Policy': 'Rescheduling Policy',
                'Scheduling Policy': 'Scheduling Policy',
                'Suggest New Time Policy': 'Suggest New Time Policy' }

  scope :expert_policies, -> { where(expert: true) }
  scope :individual_policies, -> { where(individual: true) }
  scope :global, -> { where(individual: true) }
end
