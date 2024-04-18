json.extract! device, :id, :user_id, :app_build, :device_name, :environment,
              :ios_push_notifications, :language, :os, :os_version, :time_format,
              :timezone, :token, :version
json.force_update device.force_update?
