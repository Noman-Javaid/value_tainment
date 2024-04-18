# == Schema Information
#
# Table name: experts
#
#  id                           :uuid             not null, primary key
#  bank_account_last4           :string
#  biography                    :text
#  can_receive_stripe_transfers :boolean          default(FALSE)
#  extra_user_rate              :integer
#  featured                     :boolean          default(FALSE)
#  instagram_url                :string
#  interactions_count           :integer          default(0), not null
#  linkedin_url                 :string
#  one_to_five_video_call_rate  :integer
#  one_to_one_video_call_rate   :integer
#  payout_percentage            :integer          default(80)
#  pending_events               :integer          default(0), not null
#  quick_question_rate          :integer
#  quick_question_text_rate     :integer          default(50)
#  quick_question_video_rate    :integer          default(70)
#  rating                       :float            default(0.0)
#  ready_for_deletion           :boolean          default(FALSE)
#  reviews_count                :integer
#  slug                         :string
#  status                       :integer          default("pending"), not null
#  stripe_account_set           :boolean          default(FALSE)
#  total_earnings               :integer          default(0), not null
#  twitter_url                  :string
#  video_call_rate              :integer          default(15)
#  website_url                  :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  stripe_account_id            :string
#  stripe_bank_account_id       :string
#  user_id                      :bigint           not null
#
# Indexes
#
#  index_experts_on_slug                                   (slug) UNIQUE
#  index_experts_on_user_id                                (user_id)
#  index_experts_stripe_account_id_and_set                 (stripe_account_id,stripe_account_set)
#  index_experts_stripe_account_set_and_can_get_transfers  (stripe_account_set,can_receive_stripe_transfers)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Expert < ApplicationRecord
  self.implicit_order_column = :created_at

  ## Constants
  SITE_REGEX = %r{[(htps)?:/w.a-zA-Z0-9@%_+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_+.~#?&/=]*)}.freeze
  MINIMUM_QUICK_QUESTION_RATE = 10
  MINIMUM_QUICK_QUESTION_TEXT_RATE = 10
  MINIMUM_QUICK_QUESTION_VIDEO_RATE = 20
  MINIMUM_ONE_TO_ONE_VIDEO_CALL_RATE = 1
  MINIMUM_VIDEO_CALL_RATE = 1
  MINIMUM_ONE_TO_FIVE_VIDEO_CALL_RATE = 1
  MINIMUM_EXTRA_USER_RATE = 5
  MAX_RATE = 99999

  ## Associations
  belongs_to :user, inverse_of: :expert
  has_one :availability, dependent: :destroy
  has_and_belongs_to_many :categories
  has_many :quick_questions, dependent: :destroy
  has_many :expert_calls, dependent: :destroy
  has_many :expert_interactions, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :complaints, dependent: :destroy
  has_many :time_additions, through: :expert_calls
  has_many :message_reads, as: :reader
  has_many :private_chats

  delegate :first_name, :last_name, :url_picture, :date_of_birth, :name, :email, :device,
           :allow_notifications, :active, to: :user
  delegate :validate_profile_settings?, :setting_profile?, to: :user,
                                                           allow_nil: true

  ## Validations
  before_validation :sanitize_and_correct_urls
  before_validation :generate_slug, on: :create
  validates :user, presence: true
  validates :biography, presence: true, length: { maximum: 1000 },
                        if: :validate_profile_settings?
  validates :website_url, allow_blank: true, format: { with: SITE_REGEX },
                          if: :validate_profile_settings?
  validates :twitter_url, allow_blank: true, format: { with: SITE_REGEX },
                          if: :validate_profile_settings?
  validates :instagram_url, allow_blank: true, format: { with: SITE_REGEX },
                            if: :validate_profile_settings?
  validates :linkedin_url, allow_blank: true, format: { with: SITE_REGEX },
                           if: :validate_profile_settings?
  validates :quick_question_text_rate,
            numericality: { only_integer: true, greater_than: 0 },
            presence: true, if: :validate_profile_settings?

  validates :quick_question_text_rate,
            numericality: { greater_than_or_equal_to: MINIMUM_QUICK_QUESTION_TEXT_RATE, less_than_or_equal_to: MAX_RATE },
            if: :setting_profile?

  validates :payout_percentage, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }

  validates :quick_question_video_rate,
            numericality: { only_integer: true, greater_than: 0 },
            presence: true, if: :validate_profile_settings?

  validates :quick_question_video_rate,
            numericality: { greater_than_or_equal_to: MINIMUM_QUICK_QUESTION_VIDEO_RATE, less_than_or_equal_to: MAX_RATE },
            if: :setting_profile?

  validates :video_call_rate,
            numericality: { only_integer: true, greater_than: 0 },
            presence: true, if: :validate_profile_settings?

  validates :video_call_rate,
            numericality: { greater_than_or_equal_to: MINIMUM_VIDEO_CALL_RATE, less_than_or_equal_to: MAX_RATE },
            if: :setting_profile?

  validates :total_earnings, presence: true
  validates :pending_events, presence: true

  ## Enums
  enum status: { pending: 0, verified: 1, rejected: 2 }

  ## Scopes
  scope :search_by_name, ->(name) { joins(:user).merge(User.search_by_name(name)) }

  scope :stripe_account_set, -> { where(stripe_account_set: true) }
  scope :ready_for_transfers, lambda {
    stripe_account_set.where(can_receive_stripe_transfers: true)
  }
  # TODO: change this to an attr when alt least 1 category is set or not
  scope :with_categories, -> { joins(:categories).distinct }
  scope :with_profile_set, -> { joins(:user).merge(User.active.profile_set) }
  scope :ready_for_interactions, lambda {
    ready_for_transfers.with_categories.with_profile_set
  }
  scope :active, -> { joins(:user).merge(User.active) }

  delegate :timezone, to: :user

  ## Methods and helpers
  def verify!
    self.status = :verified
    save
  end

  def reject!
    self.status = :rejected
    save
  end

  def age
    return 0 unless date_of_birth

    ((Time.zone.now - date_of_birth.to_time) / 1.year.seconds).floor # rubocop:todo Rails/Date
  end

  def pending_events_to_dollar
    (pending_events / 100.0).round(2)
  end

  def total_earnings_to_dollar
    (total_earnings / 100.0).round(2)
  end

  def add_to_total_earnings(amount)
    update!(
      pending_events: pending_events - amount, total_earnings: total_earnings + amount
    )
  end

  def reviews
    expert_interactions.with_reviews.most_recent
  end

  def total_reviews
    expert_interactions.with_reviews.count
  end

  def total_ratings
    expert_interactions.with_rating.count
  end

  def generate_slug
    slug_candidate = "#{user.first_name} #{user.last_name}".titleize if user.first_name.present? && user.last_name.present?
    slug_candidate = "#{user.email.match(/^(.+)@/)[1]}".titleize unless slug_candidate.present?
    slug_base = slug_candidate.gsub(' ', '')
    slug_counter = 1
    slug = slug_base
    while Expert.exists?(slug: slug)
      slug_counter += 1
      slug = "#{slug}#{slug_counter}"
    end

    self.slug = slug_counter > 1 ? "#{slug}" : slug_base
  end

  def payout_percentage_value
    (payout_percentage.to_f/100).to_f.round(2)
  end

  def platform_fees
    ((100 - payout_percentage.to_f)/100).to_f.round(2)
  end

  private

  # creates a stripe account and assigns the stripe_customer_id
  def set_stripe_account
    return if stripe_account_id.present?

    stripes_handler.create_account
  end

  def stripes_handler
    @stripes_individual_handler ||= Stripes::ExpertHandler.new(self) # rubocop:todo Naming/MemoizedInstanceVariableName
  end

  def sanitize_and_correct_urls
    [:website_url, :linkedin_url, :twitter_url, :instagram_url].each do |field|
      value = send(field)
      next if value.blank?

      sanitized_url = value.strip

      uri = URI.parse(sanitized_url)
      sanitized_url = "https://#{sanitized_url}" if uri.scheme.blank? || uri.scheme == 'http'

      send("#{field}=", sanitized_url)
    end
  end
end
