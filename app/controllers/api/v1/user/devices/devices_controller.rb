class Api::V1::User::Devices::DevicesController < Api::V1::UsersController
  before_action :set_device, only: %i[update]

  def update
    @device.update!(device_params)
    render '/api/v1/users/devices/update'
  end

  private

  def set_device
    @device = current_user.device || current_user.build_device
  end

  def device_params
    params.require(:device).permit(:app_build, :device_name, :environment,
                                   :ios_push_notifications, :language, :os, :os_version, :time_format,
                                   :timezone, :token, :version)
  end
end
