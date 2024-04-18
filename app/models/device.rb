# == Schema Information
#
# Table name: devices
#
#  id                     :bigint           not null, primary key
#  app_build              :string
#  device_name            :string
#  environment            :string
#  ios_push_notifications :string
#  language               :string
#  os                     :string
#  os_version             :string
#  time_format            :string
#  timezone               :string
#  token                  :string
#  version                :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Device < ApplicationRecord
  ## Constants
  IOS_OS = 'iOS'.freeze
  # TODO: change me to version that uses silent pushes
  ANDROID_APP_VERSION_WITH_SILENT_PUSH = '9.9.9'.freeze
  IOS_VERSION_TO_RECEIVE_NOTIFICATION_WITH_SUBTITLE = '10.0.0'.freeze

  DEFAULT_TIMEZONE = 'UTC'.freeze

  SEMANTIC_VERSION_REGEX = /\A([\d.]*)(\(.*\))?\z/.freeze

  ## Associations
  belongs_to :user

  ## Validations
  validates :token, uniqueness: { scope: :user_id }

  ## Methods and helpers
  def self.ransackable_scopes(_opts)
    [:search_by_user]
  end

  def self.search_by_user(query)
    Device.joins(:user).where('username ILIKE ?', "%#{query}%")
  end

  def is_ios? # rubocop:todo Naming/PredicateName
    os === IOS_OS # rubocop:todo Style/CaseEquality
  end

  def semantic_version
    return '' unless version

    SEMANTIC_VERSION_REGEX.match(version)&.captures&.first
  end

  def semantic_os_version
    return '' unless os_version

    SEMANTIC_VERSION_REGEX.match(os_version)&.captures&.first
  end

  # returns if the device can receive silent pushes
  # TODO: android needs a custom implmentationto receive silent pushes
  def silent_pushes_enable?
    # is_ios? || app_version_allowed?(ANDROID_APP_VERSION_WITH_SILENT_PUSH)
    true
  end

  def accept_notifications_with_subtitle?
    os_version_allowed?(allowed_version_to_receive_notifications_with_subtitle)
  end

  def force_update?
    return true if !version.present? # Older versions doesnt have the version saved in the db

    app_version = AppVersion.find_by(version: version, platform: os)

    return true if !app_version.present?

    app_version.force_update
  end

  def download_url
    return I18n.t('app_urls.app_store_url') if is_ios?

    I18n.t('app_urls.play_store_url')
  end

  private

  def allowed_version_to_receive_notifications_with_subtitle
    IOS_VERSION_TO_RECEIVE_NOTIFICATION_WITH_SUBTITLE if is_ios?
  end

  def app_version_allowed?(version)
    return false if semantic_version.blank?

    Gem::Version.new(semantic_version) >=
      Gem::Version.new(version)
  end

  def os_version_allowed?(os_version)
    return false if semantic_os_version.blank?

    Gem::Version.new(semantic_os_version) >=
      Gem::Version.new(os_version)
  end

  def match_version?(version)
    return false if semantic_version.blank?

    Gem::Version.new(semantic_version) == Gem::Version.new(version)
  end

end
