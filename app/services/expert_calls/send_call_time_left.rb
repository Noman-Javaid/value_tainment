class ExpertCalls::SendCallTimeLeft
  def initialize(expert_call)
    @expert_call = expert_call
  end

  # return total call duration in seconds, hold due to time_left in join response
  def call
    total_call_duration = ExpertCalls::CallDuration.new(@expert_call).call
    call_time_left = @expert_call.call_time - total_call_duration
    devices = ExpertCalls::GetDeviceList.new(@expert_call).call
    devices.each do |device|
      PushNotification::SenderJob.perform_later(
        device, 'time left', true, false, call_time_left: call_time_left
      )
    end
  end
end
