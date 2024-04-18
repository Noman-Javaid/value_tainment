class Experts::Availabilities::ParamsToAttrsMapper
  def initialize(params)
    @params = params
  end

  def call
    default_empty_hash.merge(get_days(@params[:weekdays][:days]))
                      .merge(get_days(@params[:weekend][:days]))
                      .merge(get_weekday_time_range(@params[:weekdays]))
                      .merge(get_weekend_time_range(@params[:weekend]))
  end

  private

  def get_days(days)
    days.map { |day| [day.to_sym, true] }.to_h
  end

  def get_weekday_time_range(hash_param)
    {
      time_start_weekday: hash_param[:time_start],
      time_end_weekday: hash_param[:time_end]
    }
  end

  def get_weekend_time_range(hash_param)
    {
      time_start_weekend: hash_param[:time_start],
      time_end_weekend: hash_param[:time_end]
    }
  end

  def default_empty_hash
    {
      monday: false, tuesday: false, wednesday: false, thursday: false, friday: false,
      saturday: false, sunday: false, time_start_weekday: nil, time_end_weekday: nil,
      time_start_weekend: nil, time_end_weekend: nil
    }
  end
end
