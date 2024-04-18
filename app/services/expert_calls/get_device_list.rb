class ExpertCalls::GetDeviceList
  def initialize(expert_call)
    @expert_call = expert_call
  end

  def call
    devices = []
    devices << @expert_call.expert.user.device&.token
    devices << @expert_call.individual.user.device&.token
    @expert_call.guests.each do |guest|
      devices << guest.user.device&.token
    end
    devices.compact
  end
end
