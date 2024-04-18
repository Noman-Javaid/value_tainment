# == Schema Information
#
# Table name: users
#
#  id                            :bigint           not null, primary key
#  account_deletion_requested_at :datetime
#  account_verified              :boolean          default(FALSE)
#  active                        :boolean          default(TRUE)
#  admin                         :boolean          default(FALSE)
#  allow_notifications           :boolean          default(FALSE)
#  city                          :string
#  confirmation_sent_at          :datetime
#  confirmation_token            :string
#  confirmed_at                  :datetime
#  consumed_timestep             :integer
#  country                       :string
#  country_code                  :string           default("+1")
#  current_role                  :integer          default("as_individual"), not null
#  date_of_birth                 :date
#  email                         :string           default(""), not null
#  encrypted_otp_secret          :string
#  encrypted_otp_secret_iv       :string
#  encrypted_otp_secret_salt     :string
#  encrypted_password            :string           default(""), not null
#  first_name                    :string
#  gender                        :string
#  is_default                    :boolean          default(FALSE)
#  last_name                     :string
#  otp_backup_codes              :string           is an Array
#  otp_required_for_login        :boolean
#  pending_to_delete             :boolean          default(FALSE)
#  phone                         :string
#  phone_number                  :string
#  phone_number_verified         :boolean          default(FALSE)
#  remember_created_at           :datetime
#  reset_password_sent_at        :datetime
#  reset_password_token          :string
#  status                        :string           default("registered")
#  unconfirmed_email             :string
#  zip_code                      :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  users_name_idx                       (to_tsvector('simple'::regconfig, (((first_name)::text || ' '::text) || (last_name)::text))) USING gin
#
class User < ApplicationRecord
  attr_accessor :otp_plain_backup_codes
  attr_writer :role

  ## Constants
  VALID_PICTURE_TYPES = %w[image/png image/jpeg image/jpg].freeze
  ONLY_NUMBERS_REGEX = /\A\d+\z/.freeze
  ALPHANUMERIC_REGEX = /\A[A-Za-z\d]+[-\s]?[A-Za-z\d]+\z/.freeze
  DATE_REGEX = %r{\A(19|20)\d\d[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])\z}.freeze
  VALID_GENDERS = %w[male female other].freeze
  ADMIN_ROLES = %w[admin].freeze
  APP_ROLES = %w[individual expert].freeze
  AUXILIAR_ROLES = %w[default].freeze
  DEFAULT_TIME_ZONE = 'UTC'.freeze

  ## Inheritance
  include PgSearch::Model
  include Users::StateMachine

  ## Evaluators
  pg_search_scope :search_by_name,
                  against: %i[first_name last_name],
                  ignoring: :accents,
                  using: {
                    tsearch: {
                      prefix: true
                    }
                  }
  pg_search_scope :search_by_name_and_email,
                  against: %i[first_name last_name email],
                  ignoring: :accents,
                  using: { tsearch: { prefix: true } }

  devise :two_factor_authenticatable, :two_factor_backupable,
         otp_backup_code_length: 32, otp_number_of_backup_codes: 1,
         otp_secret_encryption_key: ENV['OTP_SECRET_ENCRYPTION_KEY'] # rubocop:todo Rails/EnvironmentVariableAccess

  devise :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  ## Associations
  has_one :expert, dependent: :destroy, inverse_of: :user
  has_one :individual, dependent: :destroy, inverse_of: :user
  has_one :device, dependent: :destroy
  has_one :account_deletion_follow_up, dependent: :nullify
  has_one_attached :picture

  accepts_nested_attributes_for :expert
  accepts_nested_attributes_for :individual

  ## Validations
  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :date_of_birth, presence: true,
                            format: { with: DATE_REGEX },
                            if: :validate_profile_settings?
  validates :gender, inclusion: { in: VALID_GENDERS }, allow_blank: true,
                     if: :validate_profile_settings?
  validates :phone_number, presence: true,
                           format: { with: ONLY_NUMBERS_REGEX },
                           length: { minimum: 10, maximum: 14 },
                           if: :validate_profile_settings?
  validates :city, presence: true,
                   length: { maximum: 30 },
                   if: :validate_profile_settings?
  validates :zip_code, presence: true, format: { with: ALPHANUMERIC_REGEX },
                       length: { maximum: 12 },
                       if: :validate_profile_settings?
  validates :country, inclusion: { in: ISO3166::Country.all.map(&:alpha2) },
                      presence: true, if: :validate_profile_settings?

  validate :validate_role, unless: :admin_or_default, on: :create
  validate :picture_type_validation
  validate :default_role_exclusive_constraint
  validates :password_confirmation, presence: true, if: :password_required?

  ## Enums
  enum current_role: { as_individual: 0, as_expert: 1, as_admin: 2, as_default: 3 }

  ## Callbacks
  after_validation :disable_two_factor, on: [:save, :update],
                                        if: :phone_number_changed?
  after_validation :account_verify, on: [:save, :update, :create], if: :account_verified_changed?
  before_create :build_role, unless: :admin?
  before_create :set_allow_notifications
  after_create :set_current_role

  ## Scopes
  scope :active, -> { where(active: true) }
  scope :pending_for_deletion, -> { where(pending_to_delete: true) }
  scope :by_role, lambda { |role|
    case role
    when 'admin'
      where(admin: true)
    when 'default'
      where(is_default: true)
    when 'expert'
      joins(:expert)
    when 'individual'
      joins(:individual)
    else
      none
    end
  }

  ## Methods and helpers
  def role
    return @role if @role
    return 'default' if is_default?
    return 'expert' if expert
    return 'individual' if individual
    return 'admin' if admin?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def expert?
    expert ? true : false
  end

  def individual?
    individual ? true : false
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[by_role]
  end

  def self.roles
    ADMIN_ROLES + APP_ROLES + AUXILIAR_ROLES
  end

  def url_picture
    return nil unless picture.attached?

    Rails.application.routes.url_helpers.url_for(picture)
  end

  def validate_profile_settings?
    setting_profile? || profile_set?
  end

  def logued_with_role
    return 'expert' if as_expert?
    return 'individual' if as_individual?
    return 'admin' if as_admin?
    return 'default' if as_default?
  end

  def change_current_role!
    return if as_admin? || as_default? || !both_profiles?

    self.current_role = if as_expert?
                          'as_individual'
                        elsif as_individual?
                          'as_expert'
                        end
    save!
  end

  def both_profiles?
    return true if expert && individual

    false
  end

  # check valid role to sign in
  def self.valid_role?(role)
    APP_ROLES.include?(role)
  end

  def flag_url
    territory_flag_list = Rails.cache.fetch('territory_flag_list')
    return territory_flag_list[country] if territory_flag_list

    territory = Territory.find_by(alpha2_code: country)
    return nil unless territory

    territory.flag_url
  end

  # Generate an OTP secret if it does not already exist
  def regenerate_two_factor_secret!
    update!(otp_secret: User.generate_otp_secret)
  end

  # Ensure that the user is prompted for their OTP when they login
  def enable_two_factor!
    update!(otp_required_for_login: true)
  end

  # Disable the use of OTP-based two-factor
  def disable_two_factor!
    update!(otp_required_for_login: false, otp_secret: nil, otp_backup_codes: nil)
  end

  # Determine if backup codes have been generated
  def two_factor_backup_codes_generated?
    otp_backup_codes.present?
  end

  def validate_otp_backup_code(code)
    codes = otp_backup_codes || []

    codes.each do |backup_code|
      next unless Devise::Encryptor.compare(self.class, backup_code, code)

      return true
    end

    false
  end

  # WIP add service related to account_deletion
  # def delete_account; end

  def timezone
    device_timezone = device&.timezone if device.present?
    return device_timezone if device_timezone.present?

    return ActiveSupport::TimeZone[@individual_timezone] if ActiveSupport::TimeZone[@individual_timezone].present?

    DEFAULT_TIME_ZONE
  end

  private

  # Disable the use of OTP-based two-factor when phone is updated
  def disable_two_factor
    self.phone_number_verified = false
    self.otp_required_for_login = false
    self.otp_secret = nil
    self.otp_backup_codes = nil
  end

  def build_role
    return if expert || individual

    case role
    when 'expert'
      build_expert
    when 'individual'
      build_individual
    when 'default'
      build_individual
      build_expert
    end
  end

  def account_verify # rubocop:todo Lint/DuplicateMethods
    return if confirmed_at
    return self.confirmed_at = Time.current if account_verified

    self.confirmed_at = nil
  end

  def validate_role
    return if User.valid_role?(role) || expert || individual

    errors.add(:role, 'must be provided with value "expert" or "individual"')
  end

  def picture_type_validation
    errors.add(:picture, 'must be a JPEG, JPG or PNG file') if picture.attached? && !picture.content_type.in?(VALID_PICTURE_TYPES)
  end

  def set_allow_notifications
    self.allow_notifications = true
  end

  def set_current_role
    if admin?
      self.current_role = 'as_admin'
    elsif is_default?
      self.current_role = 'as_default'
    elsif expert
      self.current_role = 'as_expert'
    end

    save if current_role_changed?
  end

  def valid_two_factor_confirmation
    return true unless two_factor_just_set || phone_changed_with_two_factor

    self.two_factor_confirmed = false
  end

  def two_factor_just_set
    two_factor_enabled? && two_factor_enabled_changed?
  end

  def phone_changed_with_two_factor
    two_factor_enabled? && phone_changed?
  end

  def default_role_exclusive_constraint
    return unless is_default?

    errors.add(:is_default, 'must be "false" if admin is true') if admin?
  end

  def admin_or_default
    admin? || is_default?
  end
end
