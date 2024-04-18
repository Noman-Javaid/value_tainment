class Api::V1::Expert::Availability::TimeSlotsController <
      Api::V1::Expert::AvailabilitiesController
  before_action :check_valid_call_duration, only: %i[show]

  def show
    render json: {
      status: :success,
      data: {
        expert_availability:
          Availabilities::TimeSlotsCalculator.new(
            @availability, @expert, params[:date_initial], params[:date_end],
            params[:call_duration]&.to_i
          ).execute
      }
    }
  end
end
