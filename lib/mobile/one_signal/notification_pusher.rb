# frozen_string_literal: true

require 'one_signal'

# related to mobile platform interactions
module Mobile
  module OneSignal
    # send push notifications messages to a device
    class NotificationPusher
      IOS_NOTIFICATION_SOUND = 'ping.aiff'
      IOS_BADGE_TYPE = 'Increase'

      ANDROID_NOTIFICATION_SOUND = 'notification'
      ANDROID_LED_COLOR = '8A2BE2' # purple

      DEEP_LINK_NOTIFICATION_TYPE = 'deep-link'
      INFORMATIVE_NOTIFICATION_TYPE = 'informative'
      DEFAULT_NOTIFICATION_TYPE = DEEP_LINK_NOTIFICATION_TYPE

      attr_accessor :silent
      attr_reader :device, :message, :payload_data, :notification_type,
                  :result, :status, :with_sound, :extra_options

      class << self
        def app_id
          return '' if Rails.env.test?

          Rails.application.credentials.dig(Rails.env.to_sym, :one_signal, :app_id)
        end
      end

      # set the initial vars
      def initialize(device, message, payload_data: {}, # rubocop:todo Metrics/ParameterLists
                     notification_type: nil,
                     silent: false, group_id: nil, collapse_id: nil, group_message: nil,
                     with_sound: true, extra_options: {})
        @device = device
        @message = message
        @payload_data = payload_data
        @silent = silent
        @notification_type = notification_type || DEFAULT_NOTIFICATION_TYPE
        @retries = 0
        @group_id = group_id
        @collapse_id = collapse_id
        @group_message = group_message
        @with_sound = with_sound
        @extra_options = extra_options
      end

      # sends the push notification
      def execute
        return @success = true unless can_send_push_notification?

        send_push_notification
        log_data
      end

      def success?
        @success ||= result && status == '200'
      end

      protected

      def can_send_push_notification?
        device &&
          (message.present? || payload_data.present?) &&
          (!silent || device.silent_pushes_enable?)
      end

      def send_push_notification
        response = ::OneSignal::Notification.create(params: params)
        @result = response.body
        @status = response.code
      rescue ::OneSignal::OneSignalError => e
        @result = e.message
        @status = e.http_status
      rescue Errno::ECONNREFUSED, Net::ReadTimeout, Net::OpenTimeout => e
        @retries += 1
        raise Net::ReadTimeout if @retries > 5

        Rails.logger.info "Timeout (#{e.message}), retrying #{@retries} times..."
        sleep(1)
        retry
      end

      def params
        base_params.merge(os_params).merge(contents_params).merge(extra_options || {})
      end

      def base_params
        {
          app_id: self.class.app_id,
          data: data,
          collapse_id: @collapse_id
        }
      end

      def os_params
        device.is_ios? ? ios_params : android_params
      end

      def ios_params
        {
          include_ios_tokens: [device.token],
          ios_badgeType: IOS_BADGE_TYPE,
          ios_badgeCount: silent ? 0 : 1,
          ios_sound: sound,
          content_available: silent,
          thread_id: @group_id,
          summary_arg: @group_message
        }
      end

      def android_params
        {
          include_android_reg_ids: [device.token],
          android_sound: sound,
          android_led_color: ANDROID_LED_COLOR,
          android_group: @group_id,
          android_group_message: { en: @group_message }
        }
      end

      def sound
        return 'nil' unless with_sound

        device.is_ios? ? IOS_NOTIFICATION_SOUND : ANDROID_NOTIFICATION_SOUND
      end

      def contents_params
        if silent
          return device.is_ios? ? {} : { content_available: true }
        end

        return { contents: { en: message } } if message.is_a? String

        if device.is_ios? && device.accept_notifications_with_subtitle?
          {
            headings: {
              en: message[:headings]
            },
            subtitle: {
              en: message[:subtitle]
            },
            contents: {
              en: message[:contents]
            }
          }
        else
          {
            headings: {
              en: message[:headings]
            },
            contents: {
              en: "#{message[:subtitle]}\n#{message[:contents]}"
            }
          }
        end
      end

      def data
        {
          notification: {
            type: notification_type,
            data: payload_data,
            silent: silent
          }
        }
      end

      def log_data
        Rails.logger.info "Push notification sent to Token: #{device.token}, "\
                          "OS: #{device.os}, message: #{message}, "\
                          "payload: #{payload_data}, Result: #{result}, "\
                          "status: #{status}, "\
                          "silent: #{silent}"
      end
    end
  end
end
